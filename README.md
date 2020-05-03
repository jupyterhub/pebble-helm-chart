# Pebble Helm chart - Let's Encrypt in your Kubernetes CI environment!

> __WARNING__: Pebble as an ACME server and this Helm chart is _only_ meant for testing purposes, it is _not secure_ and _not meant for production_.

[Pebble](https://github.com/letsencrypt/pebble) is an [ACME](https://letsencrypt.org/docs/glossary/#def-ACME) server like [Let's Encrypt](https://letsencrypt.org/). They can provide [TLS](https://letsencrypt.org/docs/glossary/#def-TLS) [certificates](https://letsencrypt.org/docs/glossary/#def-certificate) needed for HTTPS to [ACME clients](https://letsencrypt.org/docs/client-options/) that are able to prove domain name control through an [ACME challenge](https://letsencrypt.org/docs/challenge-types/).

This [Helm chart](https://helm.sh/docs/topics/charts/) makes it easy to install Pebble in a [Kubernetes cluster](https://kubernetes.io/) along with [a DNS server](https://github.com/letsencrypt/pebble/tree/master/cmd/pebble-challtestsrv) to manipulate Pebble.



## ... why not use Let's Encrypt's staging servers instead?

In the commonly used [HTTP-01 ACME challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge), an ACME client proves its control of a domain's web server. During this challenge, the ACME server will lookup the domain name's IP and make a web request to it, and thats the problem! In an ephemeral CI environment, it is likely impossible to receive new incomming from Let's Encrypt's servers.

[![](https://mermaid.ink/img/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG4gIGF1dG9udW1iZXJcbiAgcGFydGljaXBhbnQgV2ViIFNlcnZlclxuICBwYXJ0aWNpcGFudCBBQ01FIENsaWVudFxuICBwYXJ0aWNpcGFudCBBQ01FIFNlcnZlclxuICBwYXJ0aWNpcGFudCBETlMgU2VydmVyXG4gIFxuICBhY3RpdmF0ZSBBQ01FIENsaWVudFxuXHRBQ01FIENsaWVudCAtPj4gQUNNRSBTZXJ2ZXI6IEknbSBkb2dzLmluZm8hXG4gIGRlYWN0aXZhdGUgQUNNRSBDbGllbnRcbiAgYWN0aXZhdGUgQUNNRSBTZXJ2ZXJcbiAgYWN0aXZhdGUgQUNNRSBTZXJ2ZXJcbiAgQUNNRSBTZXJ2ZXIgLS0-PiBBQ01FIENsaWVudDogUHJvb3ZlIGl0ISBTYXkgbWVlZW9vdyFcbiAgZGVhY3RpdmF0ZSBBQ01FIFNlcnZlclxuICBhY3RpdmF0ZSBBQ01FIENsaWVudFxuICBBQ01FIENsaWVudCAtLT4-IFdlYiBTZXJ2ZXI6IC4uLiB3ZSBnb3QgdG8gbWVlZW9vdyAuLi5cbiAgZGVhY3RpdmF0ZSBBQ01FIENsaWVudFxuICBOb3RlIHJpZ2h0IG9mIEFDTUUgU2VydmVyOiBJbmRlcGVuZGVudCBsb29rdXAhXG5cdEFDTUUgU2VydmVyIC0-PiBETlMgU2VydmVyOiBkb2dzLmluZm8_XG4gIGRlYWN0aXZhdGUgQUNNRSBTZXJ2ZXJcbiAgYWN0aXZhdGUgRE5TIFNlcnZlclxuICBETlMgU2VydmVyIC0-PiBBQ01FIFNlcnZlcjogMTMuMzcuMTMuMzchXG4gIGRlYWN0aXZhdGUgRE5TIFNlcnZlclxuICBhY3RpdmF0ZSBBQ01FIFNlcnZlclxuICBOb3RlIGxlZnQgb2YgQUNNRSBTZXJ2ZXI6IE5ldyBjb25uZWN0aW9uIVxuICBBQ01FIFNlcnZlciAtPj4gV2ViIFNlcnZlcjogSGkgZG9ncy5pbmZvIVxuICBkZWFjdGl2YXRlIEFDTUUgU2VydmVyXG4gIGFjdGl2YXRlIFdlYiBTZXJ2ZXJcbiAgV2ViIFNlcnZlciAtPj4gQUNNRSBTZXJ2ZXI6IG1lZWVvb3dcbiAgZGVhY3RpdmF0ZSBXZWIgU2VydmVyXG4gIGFjdGl2YXRlIEFDTUUgU2VydmVyXG4gIEFDTUUgU2VydmVyIC0-PiBBQ01FIENsaWVudDogVExTIENlcnRpZmljYXRlISBGZXRjaCFcbiAgZGVhY3RpdmF0ZSBBQ01FIFNlcnZlclxuIiwibWVybWFpZCI6eyJ0aGVtZSI6ImZvcmVzdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG4gIGF1dG9udW1iZXJcbiAgcGFydGljaXBhbnQgV2ViIFNlcnZlclxuICBwYXJ0aWNpcGFudCBBQ01FIENsaWVudFxuICBwYXJ0aWNpcGFudCBBQ01FIFNlcnZlclxuICBwYXJ0aWNpcGFudCBETlMgU2VydmVyXG4gIFxuICBhY3RpdmF0ZSBBQ01FIENsaWVudFxuXHRBQ01FIENsaWVudCAtPj4gQUNNRSBTZXJ2ZXI6IEknbSBkb2dzLmluZm8hXG4gIGRlYWN0aXZhdGUgQUNNRSBDbGllbnRcbiAgYWN0aXZhdGUgQUNNRSBTZXJ2ZXJcbiAgYWN0aXZhdGUgQUNNRSBTZXJ2ZXJcbiAgQUNNRSBTZXJ2ZXIgLS0-PiBBQ01FIENsaWVudDogUHJvb3ZlIGl0ISBTYXkgbWVlZW9vdyFcbiAgZGVhY3RpdmF0ZSBBQ01FIFNlcnZlclxuICBhY3RpdmF0ZSBBQ01FIENsaWVudFxuICBBQ01FIENsaWVudCAtLT4-IFdlYiBTZXJ2ZXI6IC4uLiB3ZSBnb3QgdG8gbWVlZW9vdyAuLi5cbiAgZGVhY3RpdmF0ZSBBQ01FIENsaWVudFxuICBOb3RlIHJpZ2h0IG9mIEFDTUUgU2VydmVyOiBJbmRlcGVuZGVudCBsb29rdXAhXG5cdEFDTUUgU2VydmVyIC0-PiBETlMgU2VydmVyOiBkb2dzLmluZm8_XG4gIGRlYWN0aXZhdGUgQUNNRSBTZXJ2ZXJcbiAgYWN0aXZhdGUgRE5TIFNlcnZlclxuICBETlMgU2VydmVyIC0-PiBBQ01FIFNlcnZlcjogMTMuMzcuMTMuMzchXG4gIGRlYWN0aXZhdGUgRE5TIFNlcnZlclxuICBhY3RpdmF0ZSBBQ01FIFNlcnZlclxuICBOb3RlIGxlZnQgb2YgQUNNRSBTZXJ2ZXI6IE5ldyBjb25uZWN0aW9uIVxuICBBQ01FIFNlcnZlciAtPj4gV2ViIFNlcnZlcjogSGkgZG9ncy5pbmZvIVxuICBkZWFjdGl2YXRlIEFDTUUgU2VydmVyXG4gIGFjdGl2YXRlIFdlYiBTZXJ2ZXJcbiAgV2ViIFNlcnZlciAtPj4gQUNNRSBTZXJ2ZXI6IG1lZWVvb3dcbiAgZGVhY3RpdmF0ZSBXZWIgU2VydmVyXG4gIGFjdGl2YXRlIEFDTUUgU2VydmVyXG4gIEFDTUUgU2VydmVyIC0-PiBBQ01FIENsaWVudDogVExTIENlcnRpZmljYXRlISBGZXRjaCFcbiAgZGVhY3RpdmF0ZSBBQ01FIFNlcnZlclxuIiwibWVybWFpZCI6eyJ0aGVtZSI6ImZvcmVzdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)



## Use case

### Good example
You develop an application that can be deployed with Kubernetes resources, and would like to verify that an automatic acquisition of TLS certificates from Let's Encrypt works as intended in a ephemeral CI environment.

### Terrible example
You want to get TLS certificates to secure HTTP traffic with HTTPS.

> __WARNING:__ While Pebble acts like a certificate authority, it should not be an certificate authority you trust. It is exposing keys and such for testing purposes. Consider all associated TLS communication as unencrypted.



## Installation

You can either install this Helm chart by itself or install it as a conditional dependency activated during tests.

### Standalone installation (recommended)
```shell
# put Helm chart configuration here...
touch pebble-config.yaml

helm repo add jupyterhub 
helm repo update
helm upgrade pebble jupyterhub/pebble --install --cleanup-on-fail --values pebble-config.yaml
```

### Sub-chart installation
> __NOTE:__ This will make a packaged Helm chart contain the sub-charts Helm templates.

Helm 3 support `Chart.yaml` files with `apiVersion: v2`, and there you can specify dependencies directly. If you want to remain compatible with Helm 2 your `Chart.yaml` has to have `apiVersion: v1` and the chart dependencies need to be specified in a separate `requirements.yaml` file.

If you install Pebble like this, you may want to make it conditionally available using [_tags_ or _conditions_](https://helm.sh/docs/topics/charts/#tags-and-condition-fields-in-dependencies).

Configuration of this chart installed as a dependency to another chart [should be nested]((https://helm.sh/docs/chart_template_guide/subcharts_and_globals/#overriding-values-from-a-parent-chart)) under a key named like the dependency or its alias.

```yaml
# Chart.yaml - modern style
apiVersion: v2
name: my-chart
# ...
dependencies:
  - name: pebble
    version: 0.1.0
    repository: https://jupyterhub.github.io/helm-chart/
    tags:
    - ci
```



## Helm chart configuration

### Configuration mechanism
Helm charts render templates using passed in a [YAML](https://www.youtube.com/watch?v=cdLNKUoMc6c) file, and this is how you configure Helm charts: by overriding values that renders templates. This is done with the `helm` CLI through the `--values my-values.yaml` flag.

### Configuring the DNS Server

Pebble can optionally be deployed with a DNS server next to it that Pebble then will use for DNS lookups. This DNS server can then be configured to point all lookups to a specific IP or have CNAME entries to point domains to other domains such as directing `example.local` to `mysvc.mynamespace`.

#### Enabling the configurable DNS Server

```yaml
challtestsrv:
  enabled: true
```

#### Default IP: Any domain -> Specified IP
You can make all DNS lookups default to a specific IP. This IP can either be set explicitly like `10.0.13.37`, or you can set it to `$(MYSVC_SERVICE_HOST)` which relies on [kublet](https://kubernetes.io/docs/concepts/overview/components/#kubelet) to add and expand the [`_SERVICE_HOST` suffixed environment variables](https://kubernetes.io/docs/concepts/services-networking/service/#environment-variables) for Kubernetes Services in the same namespace.

If `_SERVICE_HOST` environment variables are used, the Service must exist before the Pebble pod is created.

```yaml
challtestsrv:
  command:
    defaultIPv4: 10.0.13.37
    # defaultIPv4: $(MYSVC_SERVICE_HOST)
```

#### CNAME and more: Any domain -> Any domain
To initialize the DNS server with custom entries, we can use [its REST API](https://github.com/letsencrypt/pebble/tree/master/cmd/pebble-challtestsrv) and send POST requests to it when it starts up.

Here is an example to add a CNAME record pointing to a [Kubernetes Service's domain name](https://kubernetes.io/docs/concepts/services-networking/service/#dns).

```yaml
challtestsrv:
  initPostRequests:
    - path: set-cname
      data:
        host: example.local
        target: my-acme-client.my-namespace
```

### Configuring Pebble

### Mischievous behavior?
Pebble is developed to test ACME clients and ensure they are robust, so it can intentionally act mischievous.

The default of this Helm chart differs from Pebble's own defaults by making Pebble avoid slowing down certificate acquisition. See [Pebble's documentation](https://github.com/letsencrypt/pebble#testing-at-full-speed) for more info.

Below is the chart's default configuration of Pebble through environment variables. Note that if you modify `pebble.env` at all, you will override the entire array.

```yaml
pebble:
  env:
    # ref: https://github.com/letsencrypt/pebble#testing-at-full-speed
    - name: PEBBLE_VA_NOSLEEP
      value: "1"
```

#### Custom challenge ports
You can configure Pebble to connect with a domain's webserers in HTTP-01 (80) and TLS-ALPN-01 (443) challanges to non-default ports. Perhaps your web server is behind a Kubernetes service exposing it on port 8080 for example.

```yaml
pebble:
  config:
    pebble:
      httpPort: 80 # this is the port where outgoing HTTP-01 challenges go
      tlsPort: 443 # this is the port where outgoing TLS-ALPN-01 challenges go
```



## ACME Client configuration

The [ACME client](https://letsencrypt.org/docs/client-options/) needs to be aware of where to reach the ACME server (Pebble). It also needs to trust the TLS certificates used by Pebble as this communication will be using HTTPS and certificates generated before Pebble starts depending on its service name.

### 1. The ACME Server's URL

The ACME client should communicate with something like `https://pebbles-service-name.pebbles-namespace:8443/dir`. The namespace part can be omitted if Pebble is in the same namespace as the ACME client.

### 2. A TLS certificate to trust

> __WARNING:__ All HTTPS communication following trusting any certificates associated with Pebble should be treated as unsafe HTTP communication.

The ACME client and anything communicating with Pebble's actual ACME Server or [management REST API](https://github.com/letsencrypt/pebble#management-interface) needs to trust [this root certificate](helm-chart/files/root-cert.pem). Its associated [_publicly exposed key_](helm-chart/files/root-key.pem) has signed the leaf certificate Pebble will use the HTTPS communication on port 8443 and 8080.

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggVERcbiAgc3ViZ3JhcGggUGViYmxlLUNoYWxsdGVzdHNydlxuICBkbnMoRE5TKVxuICBkbnMtbWdtdChETlMgTWFuYWdlbWVudClcbiAgZW5kXG5cbiAgc3ViZ3JhcGggUGViYmxlXG4gIGFjbWUoQUNNRSkgLi0-fHVkcCt0Y3A6Ly9wZWJibGU6ODA1M3wgZG5zXG4gIGFjbWUtbWdtdChBQ01FIE1hbmFtZ2VtZW50KVxuICBlbmRcbiAgXG4gIGNsaWVudCAtLT58aHR0cHM6Ly9wZWJibGU6ODQ0M3wgYWNtZVxuICBjbGllbnQoQUNNRSBjbGllbnQpXG4gIGRldihEZXZlbG9wZXIgLyBDSSlcbiAgZGV2IC0tPnxodHRwczovL3BlYmJsZTo4MDgwfCBhY21lLW1nbXRcbiAgZGV2IC4tPnxodHRwOi8vcGViYmxlOjgwODF8IGRucy1tZ210XG4iLCJtZXJtYWlkIjp7InRoZW1lIjoiZm9yZXN0In0sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcbiAgc3ViZ3JhcGggUGViYmxlLUNoYWxsdGVzdHNydlxuICBkbnMoRE5TKVxuICBkbnMtbWdtdChETlMgTWFuYWdlbWVudClcbiAgZW5kXG5cbiAgc3ViZ3JhcGggUGViYmxlXG4gIGFjbWUoQUNNRSkgLi0-fHVkcCt0Y3A6Ly9wZWJibGU6ODA1M3wgZG5zXG4gIGFjbWUtbWdtdChBQ01FIE1hbmFtZ2VtZW50KVxuICBlbmRcbiAgXG4gIGNsaWVudCAtLT58aHR0cHM6Ly9wZWJibGU6ODQ0M3wgYWNtZVxuICBjbGllbnQoQUNNRSBjbGllbnQpXG4gIGRldihEZXZlbG9wZXIgLyBDSSlcbiAgZGV2IC0tPnxodHRwczovL3BlYmJsZTo4MDgwfCBhY21lLW1nbXRcbiAgZGV2IC4tPnxodHRwOi8vcGViYmxlOjgwODF8IGRucy1tZ210XG4iLCJtZXJtYWlkIjp7InRoZW1lIjoiZm9yZXN0In0sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)

#### Avoid confusion: there are two root certificates

The other root certificate is what Pebble use to sign certificates for its ACME clients. Pebble recreate this root certificate on startup and expose it and its associated key through the management REST API on `https://pebble:8080/roots/0` without any authorization.

### Example ACME client configuration
The ACME client needs to have the root certificate to trust, and then it must be configured to use it.

#### Creating or re-using a ConfigMap
It can be useful to have the root certificate the ACME client needs to trust within a ConfigMap that can be mounted as a file on the ACME client pod. If the Pebble Helm chart is installed in the ACME client's namespace, we can reuse a ConfigMap from it that contains the root certificate to trust, otherwise you can create one like this.

```yaml
cat <<EOF | kubectl apply --namespace <namespace-of-acme-client> -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: pebble
data:
  root-cert.pem: |
    -----BEGIN CERTIFICATE-----
    MIIDSzCCAjOgAwIBAgIIOvR7X+wFgKkwDQYJKoZIhvcNAQELBQAwIDEeMBwGA1UE
    AxMVbWluaWNhIHJvb3QgY2EgM2FmNDdiMCAXDTIwMDQyNjIzMDYxNloYDzIxMjAw
    NDI3MDAwNjE2WjAgMR4wHAYDVQQDExVtaW5pY2Egcm9vdCBjYSAzYWY0N2IwggEi
    MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCaoISLUOImo7vm7sGUpeycouDP
    TcJj6CxfCbvBsrlAg8ERGIph9H7TuDnTVk46pOaoxByGlwvvh4qR/Dled+G8NCt5
    s0r0yemY/fx1grm1TmcJRO+A1P5kx/M9hy+kVcyLRvPOnvo8Thj/4zvaJDh+pSjt
    5oAQvOHt9hYwGkkvSsZw12cTUuCsbypQ4lapDSeAjp3pNlqFcWmCvF9Ib3URDybN
    JWhY6yQQe54D2LxYqxCfYZjKhNbaxlNTlHu0Ujy75I/AdSjK6DljAZh0OimuQNEm
    FyXWvpnfyHbV5f0mMiXIOo2FY8izSD7cyFagmr0XvymCtxeDK1+MvT2pM+rXAgMB
    AAGjgYYwgYMwDgYDVR0PAQH/BAQDAgKEMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggr
    BgEFBQcDAjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBR0MgecNe4RY575
    qAtIt6zAjbBqLTAfBgNVHSMEGDAWgBR0MgecNe4RY575qAtIt6zAjbBqLTANBgkq
    hkiG9w0BAQsFAAOCAQEAjtGjoXGRG7586vyT3XcJBa8y9MOsDhQGOec23h40NJCn
    SPF28bmTIaWhB+Hv8G+Mkyf9Ov3L5L/mH0VGvZUkMAnSdT4vaMYGrTvMtYGS/8ew
    lPnlSJ3oO9Kz9zfOneoPDD1OGkV0Oq3wLn9cq6jQgItEeACsXNtaogXJxYhvxiV1
    1k/gjXmG9pvFpb0A1bw6apxGftIViDKrPR2P/pG3QAuLKywQiNxZ5odf3kvKdZmJ
    hLbu119My9XiiWhNegufcRNRNEnKJ5AQsBEwLEnD4oeIZmFvYVKOPjfWRV5qczVi
    mUPjtQv88HhlgX/lBVWJ2VONlFWVoOreZz4GkAm5bA==
    -----END CERTIFICATE-----
EOF
```

#### Mounting from a ConfigMap

```yaml
# ... within a Pod specification
volumes:
  - name: pebble-root-cert
    configMap:
      # ... if the Pebble Helm chart was installed standalone
      #     in the same namespace, with a release name of pebble.
      name: pebble
      ## ... if the Pebble chart was installed as a subchart.
      #name: {{ .Release.Name }}-pebble
containers:
  - name: my-container-with-a-lego-acme-client
    # ...
    volumeMounts:
      - name: pebble-root-cert
        subPath: root-cert.pem
        mountPath: /etc/pebble/root-cert.pem
```

#### Using LEGO and Pebble's ConfigMap

A popular ACME client in Kubernetes is [LEGO](https://github.com/go-acme/lego). It can be configured to trust a root certificate and its signed leaf certificates if it can be located with the `LEGO_CA_CERTIFICATES` environment variable.

This Helm chart has the root certificate available in a ConfigMap that can be reused (`kubectl describe configmap --namespace <namespace> pebble`), but only if the Pebble Helm chart was installed in the same namespace as the ACME client pod that will mount it. It is not possible to cannot mount a ConfigMap from another namespace!

Re-using Pebble's ConfigMap with the root certificate, mounting it on a pod with an LEGO ACME client and configuring LEGO to use it would look something like this.

```yaml
# ... within a Pod specification template of a Helm chart
volumes:
  - name: pebble-root-cert
    configMap:
      # ... if the Pebble chart is a dependency to another Helm chart
      name: {{ .Release.Name }}-pebble
      # ... if the Pebble Helm chart was installed standalone (in the same namespace!)
      name: pebble
containers:
  - name: my-container-with-a-lego-acme-client
    # ...
    volumeMounts:
      - name: pebble-root-cert
        subPath: root-cert.pem
        mountPath: /etc/ssl/cert/pebble-root-cert.pem
    env:
      - name: LEGO_CA_CERTIFICATES
        value: /etc/ssl/cert/pebble-root-cert.pem
```


## Tips and tricks

### Use K8s Services' DNS entries

Often you don't need to use the configurable DNS server to accomplish what you want. When using it, it is only used by Pebble and pods explicitly configured to use it.

A situation where you may need to use it, would be if you want to have `example.com` go to `mysvc1.namespace1.svc` and `sub.example.com` go to `mysvc2.namespace2.svc` for reasons associated with CORS or similar.

### /etc/hosts or Pod.spec.hostAlias

If you have a local Kubernetes cluster running on your computer or in a VM and can communicate with the Kubernetes services through exposed nodePorts, then request towards them will go to `localhost`. You can add an entry in `/etc/hosts` to workaround this though.

Adding this to `/etc/hosts` will make `mysvc.mynamespace` and other variants resolve to `127.0.0.1` (localhost).

```
127.0.0.1 mysvc
127.0.0.1 mysvc.mynamespace
127.0.0.1 mysvc.mynamespace.svc
127.0.0.1 mysvc.mynamespace.svc.cluster.local
```

It is also possible to manipulate a Kubernetes Pod's `/etc/hosts` file, but it should be done through the [`spec.hostAlias` configuration](https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/) to not interfere with `kubelet`.

And, it is also possible to [configure /etc/hosts on TravisCI](https://docs.travis-ci.com/user/hosts/) and presumably many other CI systems.

```yaml
# travis.yml
addons:
  hosts:
    - mysvc.mynamespace
```

### /etc/resolve.conf or Pod.spec.dnsConfig
`/etc/resolve.conf` can be configured to make use of a specific DNS server for various domains and its subdomains. Kubernetes also allows this to be configured through the [`spec.dnsConfig` configuration](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-config).

### Service.spec.externalName
A Kubernetes Service can provide CNAMEs for its own name. For example, a Kubernetes Service named `dogs` with the [`spec.externalName` configuration](https://kubernetes.io/docs/concepts/services-networking/service/#externalname) set to `dogs.info` would make `dogs`, `dogs.mynamespace`, `dogs.mynamespace.svc` etc get a CNAME entry for `dogs.info`.



## Local development

### Prerequisites

- [docker](https://docs.docker.com/get-docker/)
- [k3d](https://github.com/rancher/k3d)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)

### Setup

```shell
# clone the repo
git clone https://github.com/jupyterhub/pebble-helm-chart.git
cd pebble-helm-chart
```

```shell
# setup a local k8s cluster
k3d create --wait 60 --publish 8443:32443 --publish 8080:32080 --publish 8053:32053/udp --publish 8053:32053/tcp --publish 8081:32081
export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
```

```shell
# install pebble
helm upgrade pebble helm-chart/ --install --cleanup-on-fail --set challtestsrv.enabled=true
```

### Test

```shell
# run a basic health check
helm test pebble

kubectl logs pebble-test -c acme-mgmt
kubectl logs pebble-test -c dns-mgmt
kubectl logs pebble-test -c dns
```



## Release
