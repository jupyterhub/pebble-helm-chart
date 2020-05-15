### Advanced - Running Pebble's Challenge Test Server
During intensive testing of an ACME client itself, it could be useful to deploy [Pebble's Challenge Test Server](https://github.com/letsencrypt/pebble/tree/master/cmd/pebble-challtestsrv). This Helm chart allow you to deploy one alongside Pebble focused on its REST API configurable mock DNS.

#### Enabling the challenge test server
```yaml
challtestsrv:
  enabled: true
```

#### Making Pebble use it to lookup A/AAAA records
Note that Pebble will only make a single A/AAAA lookup directly to the specified DNS server in the `-dnsserver` flag, and, that challtestsrv will simply return fixed records as configured, it will not make any lookups itself. This means that if you just put a CNAME record in `pebble-challtestsrv`, it will not give you a A/AAAA response with an actual IP.

```yaml
pebble:
  command:
    dnsserver: ":8053"
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

#### Custom configuration on startup
To initialize the like it can be configured through the REST API, we can use its [management REST API](https://github.com/letsencrypt/pebble/tree/master/cmd/pebble-challtestsrv) and send POST requests to it when it starts up.

Here is an example to add a CNAME record pointing to a [Kubernetes Service's domain name](https://kubernetes.io/docs/concepts/services-networking/service/#dns).

```yaml
challtestsrv:
  initPostRequests:
    - path: set-cname
      data:
        host: example.local
        target: my-acme-client.my-namespace
```
