# Changelog

## 1.4

### 1.4.0 - 2025-06-26

#### Enhancements made

- Bump pebble (2.6.0 to 2.8.0), coredns, and openssl [#47](https://github.com/jupyterhub/pebble-helm-chart/pull/47) ([@consideRatio](https://github.com/consideRatio))

#### Contributors to this release

The following people contributed discussions, new ideas, code and documentation contributions, and review.
See [our definition of contributors](https://github-activity.readthedocs.io/en/latest/#how-does-this-tool-define-contributions-in-the-reports).

([GitHub contributors page for this release](https://github.com/jupyterhub/pebble-helm-chart/graphs/contributors?from=2025-01-18&to=2025-07-26&type=c))

@consideRatio ([activity](https://github.com/search?q=repo%3Ajupyterhub%2Fpebble-helm-chart+involves%3AconsideRatio+updated%3A2025-01-18..2025-07-26&type=Issues)) | @manics ([activity](https://github.com/search?q=repo%3Ajupyterhub%2Fpebble-helm-chart+involves%3Amanics+updated%3A2025-01-18..2025-07-26&type=Issues))

## 1.3

### 1.3.0 - 2025-01-19

#### New features added

- Replace minica with openssl (linux/arm64 compatibility) [#44](https://github.com/jupyterhub/pebble-helm-chart/pull/44) ([@manics](https://github.com/manics), [@consideRatio](https://github.com/consideRatio))

#### Documentation improvements

- Add RELEASE.md [#43](https://github.com/jupyterhub/pebble-helm-chart/pull/43) ([@consideRatio](https://github.com/consideRatio))

## 1.2

### 1.2.0 - 2024-09-13

With this release, pebble is upgraded from 2.5.1 to 2.6.0, and coredns
(optional) is upgraded from 1.11.1 to 1.11.3.

#### Maintenance and upkeep improvements

- Update pebble 2.5.1->2.6.0 and coredns 1.11.1->1.11.3 [#41](https://github.com/jupyterhub/pebble-helm-chart/pull/41) ([@consideRatio](https://github.com/consideRatio))

## 1.1

### 1.1.0 - 2024-03-27

With this release, pebble is upgraded from 2.3.1 to 2.5.1, and coredns
(optional) is upgraded from 1.9.3 to 1.11.1.

#### Maintenance and upkeep improvements

- tests: use new curl image [#37](https://github.com/jupyterhub/pebble-helm-chart/pull/37) ([@consideRatio](https://github.com/consideRatio))
- Update pebble from 2.3.1 from 2.5.1 [#35](https://github.com/jupyterhub/pebble-helm-chart/pull/35) ([@consideRatio](https://github.com/consideRatio))
- Update optional coredns from 1.9.3 to 1.11.1 [#34](https://github.com/jupyterhub/pebble-helm-chart/pull/34) ([@consideRatio](https://github.com/consideRatio))
- dependabot: monthly updates of github actions [#25](https://github.com/jupyterhub/pebble-helm-chart/pull/25) ([@consideRatio](https://github.com/consideRatio))

#### Documentation improvements

- docs: fix tests badge in readme [#38](https://github.com/jupyterhub/pebble-helm-chart/pull/38) ([@consideRatio](https://github.com/consideRatio))
- Add changelog for 1.0.1 [#21](https://github.com/jupyterhub/pebble-helm-chart/pull/21) ([@consideRatio](https://github.com/consideRatio))

#### Continuous integration improvements

- ci: split apart misc tests in test workflow [#36](https://github.com/jupyterhub/pebble-helm-chart/pull/36) ([@consideRatio](https://github.com/consideRatio))

## 1.0

### 1.0.1 - 2022-08-18

#### Maintenance and upkeep improvements

- bump coredns from 1.9.1 to 1.9.3 [#20](https://github.com/jupyterhub/pebble-helm-chart/pull/20) ([@consideRatio](https://github.com/consideRatio))

#### Continuous integration improvements

- Bump jupyterhub/action-k3s-helm from 2 to 3 [#19](https://github.com/jupyterhub/pebble-helm-chart/pull/19) ([@dependabot](https://github.com/dependabot))
- Bump actions/setup-python from 3 to 4 [#18](https://github.com/jupyterhub/pebble-helm-chart/pull/18) ([@dependabot](https://github.com/dependabot))
