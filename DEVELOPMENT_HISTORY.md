# Development history

In the README.md we highlight an approach to managing the domain name resolution that Pebble need to make as part of a HTTP-01 ACME challenge. In this document you get some background to other approaches considered along the way that didn't pan out.



## Initial theory

### /etc/hosts and Pod's spec.hostAlias
If you have a local Kubernetes cluster running on your computer or VM and have exposed Kubernetes services through nodePorts, then request you make from the computer or VM will be towards `localhost`. TLS certificates are valid for certain domain names, and the certificates acquired by the ACME client won't be valid for `localhost`.

There is a trick though. By adding the lines below to `/etc/hosts`, you will make `mysvc.mynamespace` and other variants resolve to `127.0.0.1` (localhost), so with those in place, you can send traffic to `mysvc.mynamespace` and have them end up at `localhost`.

```
127.0.0.1 mysvc
127.0.0.1 mysvc.mynamespace
127.0.0.1 mysvc.mynamespace.svc
127.0.0.1 mysvc.mynamespace.svc.cluster.local
```

This kind of configuration in `/etc/hosts` is also possible to do in a CI systems like [TravisCI](https://docs.travis-ci.com/user/hosts/) or in a Kubernetes Pod through the [`spec.hostAlias` configuration](https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/).

### /etc/resolve.conf or Pod.spec.dnsConfig
`/etc/resolve.conf` can be configured to make use of a specific DNS server for various domains and its subdomains. Kubernetes Pods `/etc/resolve.conf` equivalent can also be configured through the [`spec.dnsConfig` configuration](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-config).

### Service.spec.externalName
While normal Kubernetes Services get a DNS records in the Kubernetes cluster's primary DNS server pointing to its ClusterIP, the `ExternalName` type of Kubernetes Service will instead get a CNAMEs record but no ClusterIP. For example, a Kubernetes Service named `dogs` with the [`spec.externalName` configuration](https://kubernetes.io/docs/concepts/services-networking/service/#externalname) set to `dogs.info` would make `dogs`, `dogs.mynamespace`, `dogs.mynamespace.svc`, and `dogs.mynamespace.svc.cluster.local` get a CNAME entry for `dogs.info`.

Not having a ClusterIP means that this Kubernetes Service cannot accept any network traffic, it simply influences the Kubernetes cluster's DNS server by adding a CNAME record for the service name to a specified target domain.



## The DNS hurdles

To facilitate testing against an ACME server, we need partial control over DNS resolution. After some experimentation and consideration, I concluded some good outcomes to aim for.

### Goals

1. __ACME client independent configuration__

   Many ways to configuring Pebble and a DNS requires information about the ACME client's Kubernetes Service's ClusterIP. This information in turn can require _hardcoding_ of a ClusterIP or _first installing the ACME client_.
   
   - Hardcoding the ACME clients ClusterIP isn't great because it requires you to be able to do it, as well as knowledge about the Kubernetes clusters allowed network ranges for Services.
   - First installing the ACME client isn't great because it will then startup without the ACME server ready, which may put it in a failure state which needs to be cleared.

2. __Kubernetes wide DNS configuration__

   While it is essential to have Pebble's DNS lookups resolve to the ACME client's Kubernetes service ClusterIP, a is a nice bonus to let every Kubernetes Pod's lookup resolve in the same way.

3. __Helm chart local configuration only__

   It is good to avoid assuming knowledge about other services, for example what DNS server is used in the Kubernetes cluster. I'm not sure if it could be possible to reach this goal along with goal #2, but I've given up on it as I believe it would introduce too much complexity if I'd pursue it.

### Failures along the way

I didn't have the goals above explicit when I started out, but they were realized by some failure along the way. But quite early on I got aiming for Goal 1. I wanted to use my ACME client's Kubernetes Service's local domain name instead of its ClusterIP!

#### Pebble's `-dnsserver` flag

The `pebble-challtestsrv` binary that can act as a REST API configurable DNS server, and `pebble` as an ACME server can startup listening specifically to a DNS server through the `-dnsserver` flag.

But apparently, when Pebble isn't configured with a specific DNS server to use through the `-dnsserver` flag, Pebble will deviate from [how it normally resolves IPs](https://github.com/letsencrypt/pebble/blob/52b92744eaad895ac25b19dae429c0bdd134b764/va/va.go#L617-L619) and [will only lookup A (ipv4) and AAAA (ipv6) records](https://github.com/letsencrypt/pebble/blob/52b92744eaad895ac25b19dae429c0bdd134b764/va/va.go#L629-L657) specifically, and bypassing any CNAME associated logic.

I hoped that I would be able to add a CNAME entry that would point to my ACME client's Kubernetes Service, like `mysvc.mynamespace.svc.cluster.local` and it would be fine. But, the CNAME entry is entirely ignored as with `-dnsserver` configured, Pebble is making a dedicated `A` and `AAAA` record lookup that ignores any CNAME entry.

This meant that using Pebble's `-dnsserver` flag.

#### Pebble's (Pod.)spec.dnsConfig

My next hope was that by configuring Pebble's Kubernetes Pod with [`spec.dnsConfig`](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#poddnsconfig-v1-core), I could make Pebble perform a normal lookup instead. I had read in [this Quora answer](https://www.quora.com/How-do-CNAME-records-work/answer/Vern-Hart) and [this text](https://ns1.com/resources/cname), that a DNS client not getting an A/AAAA record but a CNAME record would make a new request.

Here are some traces of things I tried along the way.

```
# kubect get svc pebble -> 10.43.91.232 / which exposes pebble-challtestsrv's DNS server
kubectl run -it --rm --restart=Never --image=busybox busybox --overrides '{ "spec": { "dnsPolicy": "ClusterFirst", "dnsConfig": { "nameservers": ["10.43.205.235"] } } }' -- nslookup mysvc.test
```

... I tried to debug lookups in my Kubernetes wide DNS server (CoreDNS).

```
kubectl edit configmap -n kube-system coredns
# inserted "log" below "ready" in the Corefile
kubectl delete pod -n kube-system -l k8s-app=kube-dns

kubectl logs -n kube-system deploy/coredns
```

... I gave up this path.

#### Kubernetes Service: type ExternalName

Kubernetes Services of type [ExternalName](https://kubernetes.io/docs/concepts/services-networking/service/#externalname) will [can not have an IP](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services). I hoped for a while I could point Pebble to this IP, and let it's external name point onwards to something else.

```yaml
{{- if and .Values.challtestsrv.enabled .Values.challtestsrv.defaultDestinationService.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "pebble.fullname" . }}-default-destination
  labels:
    {{- include "pebble.labels" . | nindent 4 }}
spec:
  type: ExternalName
  externalName: {{ .Values.challtestsrv.defaultDestinationService.externalName | required "With challtestsrv.defaultDestinationService enabled, its externalName is required." }}
{{- end }}
```
