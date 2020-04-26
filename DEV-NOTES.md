- DONE: make challtestsrv a DNS thing that can be enabled/disabled
- NO: make pebble/challtestsrv dedicated deployments? No reason.
- YES: dynamically based on where pebble is located with minica? Perhaps in the future.
- NO: dynamically based on where pebble is located with a k8s CSR? No, overkill.

Idea:
- ACME server that k8s CSR to provision certs
- Ensure challtestsrv.command.defaultIPv4 like $(MYSVC_SERVICE_HOST) evaluates?
  - No: Helm will always install the Service before the deployment reference it,
    so unless the Pebble chart is installed separately before the chart it
    reference, this isn't a problem to manage. Helm installs resources in a
    certain order, and [Services comes before
    Deployments](https://github.com/helm/helm/blob/d5d96ed3cf1c7b555a3381c370faf99eb0dcc42f/pkg/releaseutil/kind_sorter.go#L31),
    no matter if they come from dependency charts because Helm treats all
    chart's resources, dependencies or not, like a big set when it installs
    them.
- Allow injectiong of CNAMEs on startup ANYTHING -> my-svc for example.
  - Perhaps: this could perhaps be done through a postStart exec lifecycle hook
    with a mounted script or executable, or with a third party container.
- Set securityContext

Scope:
- Limit to use in the same namespace

With initPostRequests, pebble can communicate with other namespaces
With dynamic creation of certs from a fixed root cert, pebble can be located wherever.
