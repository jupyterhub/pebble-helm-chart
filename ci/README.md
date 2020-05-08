## Initial setup of a deployment key for jupyterhub/helm-chart

1. Create a new SSH key to register as a GitHub deploy key for the jupyterhub/helm-chart repo.

```
ssh-keygen -t ed25519 -C "jupyterhub/pebble-helm-chart" -f ci/publish-id_ed25519
```

2. Register the public part of the SSH key [with GitHub to have write access to the jupyterhub/helm-chart](https://github.com/jupyterhub/helm-chart/settings/keys) repo

3. Install the [travis cli](https://github.com/travis-ci/travis.rb#readme)

4. Encrypt the SSH key's private part like [these instructions](https://docs.travis-ci.com/user/encrypting-files/#automated-encryption)

```
travis encrypt-file ci/publish-id_ed25519
```

5. Use the output of the step before to update `ci/publish`.

```shell
# this command was provided from the earlier steps output
openssl aes-256-cbc -K $encrypted_dae848772642_key -iv $encrypted_dae848772642_iv -in ci/publish-id_ed25519.enc -out ci/publish-id_ed25519 -d
```
