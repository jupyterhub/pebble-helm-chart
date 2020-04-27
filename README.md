# Pebble - A Helm chart

> __WARNING__: Pebble and this Helm chart is _only_ meant for testing purposes.

This [Helm chart](https://helm.sh/docs/topics/charts/) is useful for testing
interaction's with Let's Encrypt in a Kubernetes cluster that cannot receive
incoming traffic from Let's Encrypt. This is common need for developers of Helm
charts that wants to test them in a CI environment.

[Pebble](https://github.com/letsencrypt/pebble) is an
[ACME](https://letsencrypt.org/docs/glossary/#def-ACME) server like [Let's
Encrypt](https://letsencrypt.org/). It can provide
[certificates](https://letsencrypt.org/docs/glossary/#def-certificate) for
[TLS](https://letsencrypt.org/docs/glossary/#def-TLS) (as needed for HTTPS
communication) to those able to proove domain ownership through an [ACME
challenge](https://letsencrypt.org/docs/challenge-types/).

Pebble can optionally rely on
[pebble-challtestsrv](https://github.com/letsencrypt/pebble/tree/master/cmd/pebble-challtestsrv)
as a DNS server that is configurable through a REST API. This is useful to make
[HTTP-01](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) and
[TLS-ALPN-01](https://letsencrypt.org/docs/challenge-types/#tls-alpn-01) ACME
challenges find their way to your [ACME
client](https://letsencrypt.org/docs/client-options/).

## Configuration

To make Pebble rely on a configurable DNS server running in the
pebble-challtestsrv executable, just enable it.

```yaml
challtestsrv:
  enabled: true
```

To make the configurable DNS lookup go to a specific Kubernetes Service IP,
configure it like below assuming the Pebble Helm chart was installed in the same
namespace as the referenced Kubernetes service.

```yaml
challtestsrv:
  command:
    defaultIPv4: $(MY_SVC_SERVICE_HOST)
```

To initialize the configurable DNS server further, we can send POST requests to
it directly after it has started up.

```yaml
challtestsrv:
  initPostRequests:
    - path: set-cname
      data:
        host: example.local
        target: my-svc.my-namespace.svc.cluster.local
```

## Limitations

This Pebble Helm chart needs to be installed in the same namespace as the ACME client to work with. This is because:
- The HTTPS certs created is only valid for "localhost" and "pebble", and not
  "pebble.pebble", "pebble.pebble.svc", or "pebble.pebble.svc.cluster.local".
  This can be fixed by dynamically creating the certificates from a fixed root
  certificate that ACME clients can trust.
- If you want to use Pebble's ConfigMap that contains the root cert to trust for
  ACME communication over HTTPS, you must be in the same namespace.
- If you want to use the Kubernetes set environment variables providing for
  services IP addresses, you must reside in the same namespace as the service.

The `fullnameOverride` configuration is set to `"pebble"` to ensure the
Kubernetes service name it is `pebble`, which makes the certificate it use
valid. It is hardcoded at the moment to be valid for the domain names
`localhost` and `pebble`.

## Installation

You can either install it in the same namespace or mark it as a dependency.

```shell
# TODO
helm upgrade --install --cleanup-on-fail ...
```

```yaml
# TODO
dependencies:
  ...
```

## ACME Client configuration

Assuming you have an [ACME client](https://letsencrypt.org/docs/client-options/)
behind the Kubernetes service `my-svc` in the namespace `my-namespace`, and the
Pebble Helm chart is installed in the same namespace, you should configure the
ACME client it to work against the ACME server `https://pebble/dir`.

A common ACME client is [LEGO](https://github.com/go-acme/lego). Assuming LEGO
is running in a Pod you want to work against the Pebble ACME server, you must
first ensure it trusts the _publically exposed_ root certificate to be able to
speak with Pebble, something like this needs to be declared.

> __WARNING:__ Pebble is setup with a TLS certificate signed by a publically
exposed root certificate key, so don't trust this any more than you trust HTTP,
because the public key can be used to decipher the traffic.

```yaml
# ... within a Pod specification template of a Helm chart
volumes:
  - name: pebble-cert
    configMap:
      # ... if the Chart depends on the Pebble Helm chart
      name: {{ .Release.Name }}-pebble
      # ... else if the Pebble Helm chart was installed standalone (in the same namespace!)
      name: pebble
containers:
  - name: my-container-with-a-lego-acme-client
    # ...
    volumeMounts:
      - name: pebble-cert
        subPath: root-cert.pem
        mountPath: /etc/ssl/cert/pebble-root-cert.pem
    env:
      - name: LEGO_CA_CERTIFICATES
        value: /etc/ssl/cert/pebble-root-cert.pem
```
