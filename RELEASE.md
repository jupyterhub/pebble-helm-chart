## Release

To make a release, get a changelog PR merged, and push a tag of the changelog
PRs merge commit.

```bash
# verify your latest commit is up to date
# and its the commit to be tagged
git log

git tag -a 1.2.3 -m 1.2.3
git push --follow-tags
```
