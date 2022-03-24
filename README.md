# Pebble Helm chart - Let's Encrypt for unreachable CI environment with Kubernetes!

[![GitHub Workflow Status - Test](https://img.shields.io/github/workflow/status/jupyterhub/pebble-helm-chart/test?logo=github&label=tests)](https://github.com/jupyterhub/zero-to-jupyterhub-k8s/actions)
[![Latest stable release of the Helm chart](https://img.shields.io/badge/dynamic/json.svg?label=stable&url=https://jupyterhub.github.io/helm-chart/info.json&query=$.pebble.stable&colorB=orange&logo=helm)](https://jupyterhub.github.io/helm-chart#pebble)
[![Latest development release of the Helm chart](https://img.shields.io/badge/dynamic/json.svg?label=dev&url=https://jupyterhub.github.io/helm-chart/info.json&query=$.pebble.latest&colorB=orange&logo=helm)](https://jupyterhub.github.io/helm-chart#development-releases-pebble)
[![GitHub](https://img.shields.io/badge/issue_tracking-github-blue?logo=github)](https://github.com/jupyterhub/pebble-helm-chart/issues)
[![Discourse](https://img.shields.io/badge/help_forum-discourse-blue?logo=discourse)](https://discourse.jupyter.org/c/jupyterhub)
[![Gitter](https://img.shields.io/badge/social_chat-gitter-blue?logo=gitter)](https://gitter.im/jupyterhub/jupyterhub)


> __WARNING__: Pebble as an ACME server and this Helm chart is _only_ meant for testing purposes, it is _not secure_ and _not meant for production_.

[Pebble](https://github.com/letsencrypt/pebble) is an [ACME](https://letsencrypt.org/docs/glossary/#def-ACME) server like [Let's Encrypt](https://letsencrypt.org/). ACME servers can provide [TLS](https://letsencrypt.org/docs/glossary/#def-TLS) [certificates](https://letsencrypt.org/docs/glossary/#def-certificate) for HTTP over TLS ([HTTPS](https://en.wikipedia.org/wiki/HTTPS)) to [ACME clients](https://letsencrypt.org/docs/client-options/) that are able to prove control over a domain name through an [ACME challenge](https://letsencrypt.org/docs/challenge-types/).

This [Helm chart](https://helm.sh/docs/topics/charts/) makes it easy to install Pebble in a [Kubernetes cluster](https://kubernetes.io/) using [Helm](https://helm.sh/) and work with fake domain names.



## Motivation

This Helm chart is meant to help test applications deployments against an ACME server like Let's Encrypt from a _unreachable_ CI environments, because using [Let's Encrypts staging environment](https://letsencrypt.org/docs/staging-environment/) likely wouldn't work there.

In the commonly used [HTTP-01 ACME challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge), an ACME client need to prove its control of a domain's web server. During this challenge, the ACME server will first independently lookup the domain name's IP, and make a web request to it, and that's the problem! The domain name needs to be publicly recognized as well as accessible, both these parts are problematic while working with an ephemeral CI environment.



## Overview

This Helm chart deploys an ACME server (Pebble) and a DNS server ([CoreDNS](https://coredns.io/)) that the ACME server will rely on for domain lookups, which you can configure as you please ([Corefile](https://coredns.io/manual/toc/#configuration)).

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggTFJcbiAgdXNlci1ob3N0cygvZXRjL2hvc3RzKVxuICB1c2VyKFVzZXIpXG4gIGFwcChXZWIgU2VydmVyKVxuICBhcHAtY2VydChUTFMgQ2VydGlmaWNhdGUpXG4gIGFwcC1hY21lLWNsaWVudChBQ01FIGNsaWVudClcbiAgYWNtZS1zZXJ2ZXIoQUNNRSBTZXJ2ZXIpXG4gIGFjbWUtZG5zKENvcmVETlMpXG4gIGFjbWUtZG5zLWNvbmZpZyhDb3JlZmlsZSlcbiAgazhzLWRucyhLOHMgRE5TKVxuXG4gIHN1YmdyYXBoIEt1YmVybmV0ZXNcbiAgc3ViZ3JhcGggUGViYmxlIEhlbG0gY2hhcnRcbiAgYWNtZS1zZXJ2ZXJcbiAgYWNtZS1zZXJ2ZXIgLS0-IGFjbWUtZG5zXG4gIGFjbWUtZG5zLWNvbmZpZyAuLSBhY21lLWRuc1xuICBlbmRcblxuICBhY21lLWRucy0tPms4cy1kbnNcbiAgXG4gIHN1YmdyYXBoIEFwcFxuICBhcHAtYWNtZS1jbGllbnQgLi0-IGFwcC1jZXJ0XG4gIGFwcC1hY21lLWNsaWVudCA8LS0-IGFjbWUtc2VydmVyXG4gIGFwcCAuLSBhcHAtY2VydFxuICBlbmRcbiAgZW5kXG5cbiAgc3ViZ3JhcGggVXNlciBlbnZpcm9ubWVudFxuICB1c2VyLWhvc3RzIC4tIHVzZXJcbiAgdXNlciAtLT58aHR0cHM6Ly9hcHAudGVzdHwgYXBwXG4gIGVuZFxuIiwibWVybWFpZCI6eyJ0aGVtZSI6ImZvcmVzdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggTFJcbiAgdXNlci1ob3N0cygvZXRjL2hvc3RzKVxuICB1c2VyKFVzZXIpXG4gIGFwcChXZWIgU2VydmVyKVxuICBhcHAtY2VydChUTFMgQ2VydGlmaWNhdGUpXG4gIGFwcC1hY21lLWNsaWVudChBQ01FIGNsaWVudClcbiAgYWNtZS1zZXJ2ZXIoQUNNRSBTZXJ2ZXIpXG4gIGFjbWUtZG5zKENvcmVETlMpXG4gIGFjbWUtZG5zLWNvbmZpZyhDb3JlZmlsZSlcbiAgazhzLWRucyhLOHMgRE5TKVxuXG4gIHN1YmdyYXBoIEt1YmVybmV0ZXNcbiAgc3ViZ3JhcGggUGViYmxlIEhlbG0gY2hhcnRcbiAgYWNtZS1zZXJ2ZXJcbiAgYWNtZS1zZXJ2ZXIgLS0-IGFjbWUtZG5zXG4gIGFjbWUtZG5zLWNvbmZpZyAuLSBhY21lLWRuc1xuICBlbmRcblxuICBhY21lLWRucy0tPms4cy1kbnNcbiAgXG4gIHN1YmdyYXBoIEFwcFxuICBhcHAtYWNtZS1jbGllbnQgLi0-IGFwcC1jZXJ0XG4gIGFwcC1hY21lLWNsaWVudCA8LS0-IGFjbWUtc2VydmVyXG4gIGFwcCAuLSBhcHAtY2VydFxuICBlbmRcbiAgZW5kXG5cbiAgc3ViZ3JhcGggVXNlciBlbnZpcm9ubWVudFxuICB1c2VyLWhvc3RzIC4tIHVzZXJcbiAgdXNlciAtLT58aHR0cHM6Ly9hcHAudGVzdHwgYXBwXG4gIGVuZFxuIiwibWVybWFpZCI6eyJ0aGVtZSI6ImZvcmVzdCJ9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)



## Installation

```shell
# Note that pebble is written twice below, the first is the helm chart name as
# found in the Helm chart repository while the second is the name of the
# "helm release" which is the Helm official terminology for an installation
# of a Helm chart.
helm install pebble pebble --repo=https://jupyterhub.github.io/helm-chart/
```



## Chart configuration

To configure the Helm chart, create `my-values.yaml` to pass with the `--values` flag during `helm install` or `helm upgrade`.

Helm charts _render templates_ into Kubernetes yaml files using _configurable values_. Helm charts contain default values, and these can be overridden in a merging process during chart installation and upgrades, for example with the `--values` flag to pass a [YAML](https://www.youtube.com/watch?v=cdLNKUoMc6c) file with values or with the `--set` flag to override specific keys' values.


### CoreDNS configuration options

Pebble as an ACME server during ACME challenges will make DNS lookups. This Helm chart makes those lookups go through a dedicated [CoreDNS](https://coredns.io/) DNS server that you can configure to manipulate what IP address various lookups should resolve to. Without additional configuration, it will just reference the Kubernetes cluster's DNS server.

CoreDNS configuration is documented [here](https://coredns.io/manual/toc/#configuration), and the current configuration can be inspected like this.

```shell
# Pebble's current configuration of CoreDNS
kubectl get configmap --all-namespaces -l app.kubernetes.io/name=pebble-coredns -o jsonpath='{.items[0].data.Corefile}'
```

You can inject a section in this configuration through Pebble's Helm chart configuration, for example like this.

```yaml
# Pebble's Helm chart configuration (my-values.yaml)
coredns:
  # make all DNS lookups to "test" and subdomains go to the
  # Kubernetes service named mysvc in the same namespaces as
  # Pebble is installed
  corefileSegment: |-
    template ANY ANY test {
      answer "{{ .Name }} 60 IN CNAME mysvc.{$PEBBLE_NAMESPACE}.svc.cluster.local"
    }
```

__Notes about the example above__
1. `{$ENV_VAR_NAME}` is the syntax to reference environment variables.
2. `PEBBLE_NAMESPACE` is an environment variable explicitly on the CoreDNS pod to reference the namespace where Pebble is installed.
3. We provide a `CNAME` record that acts like an alias domain name, which IP is in turn looked up by CoreDNS with the Kubernetes cluster's DNS server.
4. The CNAME must reference the full domain name, not only `mysvc` for example.

__Referencing the CoreDNS server__

You may want other lookups to also go to this DNS server. It is available through this Kubernetes service.

```shell
# Pebble's CoreDNS Kubernetes service
kubectl get svc --all-namespaces -l app.kubernetes.io/name=pebble-coredns
```

You then have many options which can't be covered here, but here are some noteworthy pieces to be aware about.

1. [Kubernetes Service's environment variables](https://kubernetes.io/docs/concepts/services-networking/service/#environment-variables)
2. [Kubernetes Pod's DNS config](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config)
3. [Kubernetes clusters own DNS server's configuration](https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/)


### Pebble configuration options

__Custom challenge ports__
During a HTTP-01 (80) and TLS-ALPN-01 (443) challenge, Pebble will connect to the domains IP address using specific ports, but since it is meant for testing, you can configure these ports. This is useful if your ACME client is behind a Kubernetes service exposing it on port 8080 for example.

```yaml
pebble:
  config:
    pebble:
      httpPort: 80 # this is the port where outgoing HTTP-01 challenges go
      tlsPort: 443 # this is the port where outgoing TLS-ALPN-01 challenges go
```

__Mischievous behavior?__

Pebble is developed to test ACME clients and ensure they are robust, so it can intentionally act mischievous.

The default of this Helm chart seen below configures Pebble to ensure speedy certificate acquisition. Note that if you provide an array to `pebble.env`, it will override the default array of environment variables.

```yaml
pebble:
  env:
    ## ref: https://github.com/letsencrypt/pebble#testing-at-full-speed
    - name: PEBBLE_VA_NOSLEEP
      value: "1"
    ## ref: https://github.com/letsencrypt/pebble#invalid-anti-replay-nonce-errors
    - name: PEBBLE_WFE_NONCEREJECT
      value: "0"
    ## ref: https://github.com/letsencrypt/pebble#authorization-reuse
    - name: PEBBLE_AUTHZREUSE
      value: "100"
```

See [Pebble's documentation](https://github.com/letsencrypt/pebble#testing-at-full-speed) for more info about its mischievous behavior.



## ACME Client configuration
The [ACME client](https://letsencrypt.org/docs/client-options/) needs configuration about where Pebble as an ACME server is and that it should accept the root TLS certificates signing the leaf TLS certificates used for Pebble's own HTTPS communication.


### 1. Provide an URL
Typically you should provide `https://pebble/dir`, but generally `https://pebbles-service-name.pebbles-namespace/dir` if Pebble is renamed or your ACME client is in another Kubernetes namespace.

```shell
PEBBLE_SERVICE_NAME=$(kubectl get svc --all-namespaces -l app.kubernetes.io/name=pebble -o jsonpath='{.items[0].metadata.name}')
PEBBLE_NAMESPACE=$(kubectl get svc --all-namespaces -l app.kubernetes.io/name=pebble -o jsonpath='{.items[0].metadata.namespace}')
echo https://${PEBBLE_SERVICE_NAME}.${PEBBLE_NAMESPACE}/dir
```


### 2. Accept a certificate
> __WARNING:__ Never trust a root certificate with exposed key, you may think the communication is secure!

Communication with Pebble's ACME server and its [management REST API](https://github.com/letsencrypt/pebble#management-interface) requires accepting a certificate Pebble use. Pebble will use a _leaf certificate_ dynamically created with this _unsafe_ [root certificate](pebble/files/root-cert.pem) and [key](pebble/files/root-key.pem).

__Watch out for confusion!__

There are two different root certificates to discuss!

One root certificate is associated with Pebble's own communication, and the other is ephemeral and what Pebble use to create certificates for its ACME clients completing ACME challenges. Pebble recreates the ephemeral root certificate on startup and exposes it and its associated key through the management REST API on `https://pebble:8444/roots/0`.


### Example ACME client configuration
The ACME client will need to be configured to either accept all certificates or accept the root certificate to trust and be configured to trust it. In this example we will assume we explicitly provide the certificate to trust, and that we use the [LEGO](https://github.com/go-acme/lego) ACME client.

__A Kubernetes ConfigMap for the root certificate__

We are going to put the root certificate for the ACME client to trust within a Kubernetes ConfigMap, declare it as a volume in the ACME client's pod, and then mount it as a file in the pod's container.

If the ACME client is in the Kubernetes namespace where Pebble was installed, the ACME client can reference an existing ConfigMap that contains the root certificate it needs to trust. The ConfigMap can be identified like this.

```shell
# the configmap with the root certificate the ACME client need to trust
kubectl get configmap --all-namespaces -l app.kubernetes.io/name=pebble
```

If the ACME client was in a different namespace, you can create create a ConfigMap in its namespace like this.

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

__Mounting the ConfigMap__

With a ConfigMap available in the ACME client's namespace, presumable named `pebble` and having a key named `root-cert.pem`, we can now mount it as a file in a pod where the ACME client runs.

```yaml
# ... within a Pod specification where the ACME client runs
volumes:
  - name: pebble-configmap
    configMap:
      name: pebble  # name of configmap
containers:
  - name: my-container-with-an-acme-client
    # ...
    volumeMounts:
      - name: pebble-configmap  # name of volume
        subPath: root-cert.pem  # name of specific key in configmap
        mountPath: /etc/pebble/root-cert.pem  # name of file to mount
```

__Referencing the certificate file__

In this example where we presume the [LEGO](https://github.com/go-acme/lego) ACME client, we configure it to trust a root certificate and its signed leaf certificates through the `LEGO_CA_CERTIFICATES` environment variable.

```yaml
# ... within a Pod specification where a LEGO ACME client runs
containers:
  - name: my-container-with-a-lego-acme-client
    # ...
    env:
      - name: LEGO_CA_CERTIFICATES
        value: /etc/pebble/root-cert.pem  # reference the mounted file!
```



## Local development

### Prerequisites
- [docker](https://docs.docker.com/get-docker/)
- [k3d](https://github.com/rancher/k3d)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)


### Setup
```shell
# clone the git repo
git clone https://github.com/jupyterhub/pebble-helm-chart.git
cd pebble-helm-chart
```

```shell
# setup a local k8s cluster
k3d create --wait 60 --publish 8443:32443 --publish 8444:32444 --publish 8053:32053/udp --publish 8053:32053/tcp
export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"
```

```shell
# install pebble
helm upgrade --install pebble ./pebble --cleanup-on-fail
```


### Test
```shell
# run a basic health check
helm test pebble

kubectl logs pebble-test --all-containers --prefix
kubectl logs pebble-coredns-test --all-containers --prefix
kubectl logs deploy/pebble --all-containers --prefix
kubectl logs deploy/pebble-coredns --all-containers --prefix
```



## Release

No changelog or similar yet. Making a release is as easy as pushing a tagged commit on the main branch.

```
git tag -a x.y.z -m x.y.z
git push --follow-tags
```
