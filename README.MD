# GeneralRedneck Packagist

This is the repository for https://generalredneck.github.io/packages

The purpose of this repository is to house all the custom packages used across
all of the Ensemble sites. This makes it easier than adding a separate
`repositories` entry to composer.json for every site that would use a custom
package such as the `drupal-libraries` version of dropzone/dropzone. Instead
all we have to add is the following snipped to a site's `repositories` section
to get access to all the custom packages and repositories defined in this here.

```json
  {
    "type": "composer",
    "url": "https://generalredneck.github.io/packages"
  }
```
## Requirements

* Github access to all private repos defined in statis.json
* Composer configured with your github authentication token.

## How to Develop

This repository comes with a lando instance that sets you up with the ability
to test the repositories. To begin with run:

```bash
composer install
composer run build
lando start
```

**Note:** In order for this to succeed you must have Github access to all the
repositories defined in `satis.json`.

You should now be able to navigate to http://gr-packages.lndo.site/ and see all
the packages and versions currently defined in `satis.json`.

### Adding a New Package

To add a new package, add a repositories entry just like you would to a normal
`composer.json` to `satis.json`

Example, if I want to add a new private custom module, I may add the following
entry

```json
  {
    "type": "vcs",
    "url": "https://github.com/vendor/repo.git"
  }
```

or if I need a new custom drupal library

```json
  {
    "type": "package",
    "package": {
      "name": "drupal-library/blazy",
      "version": "1.8.2",
      "type": "drupal-library",
      "dist": {
        "url": "https://github.com/dinbror/blazy/archive/1.8.2.zip",
        "type": "zip"
      },
      "require": {
        "composer/installers": "^1.2.0"
      }
    }
  }
```

Please reference Composer's documentation on the
[Repositories](https://getcomposer.org/doc/05-repositories.md) property.

### Testing

Once you have finished run `composer run build` from your host machine (since
it has your github authentication and lando would not). Then, using another
project change the composer url to https://gr-packages.lndo.site. Additionally
add  `"secure-http":false,` to the config section since lando's https
certificate is insecure by default.

```json
{
  ...
  "repositories": [
    {
      "type": "composer",
      "url": "https://gr-packages.lndo.site"
    }
    ...
  ],
  ...
  "config": {
    ...
    "secure-http": false
  }
  ...
}
```

### Pushing Up the Change

Make a PR. Put in a request for review to someone on the team.

### Making the Changes Live

Simply pushing a commit to the main branch will fire off Circle CI. This will
compile and push the packagist files to S3 where they are served. It's all
static content.

## How to Update This Packagist With Version Changes.

Not all packages version changes are manual changes to `satis.json`. Common
examples of this is when you use a `vcs` style repository entry. In this case,
the custom module should have a Circle CI job or webhook that hits our Circle CI
deployment job. You will want this to happen on every commit because all new
tags and branches can be a new version. It takes only a few seconds to build.

Here are some example calls to the deployment job.

In Bash:
```bash
curl --request POST \
--url https://circleci.com/api/v2/project/github/generalredneck/generalredneck_satis/pipeline \
--header "Circle-Token: $CIRCLE_TOKEN" \
--header "content-type: application/json" \
--data '{"parameters":{"run_dependency_update":true}}'
```

In Circle CI:
```yml
version: 2.1
jobs:
  update-packagist:
    docker:
      - image: cimg/base:2021.12
    steps:
      - run: "curl --request POST --url https://circleci.com/api/v2/project/github/generalredneck/generalredneck_satis/pipeline --header \"Circle-Token: $CIRCLE_TOKEN\" --header \"content-type: application/json\" --data '{\"parameters\":{\"run_dependency_update\":true}}'"
workflows:
  build:
    jobs:
      - update-packagist:
          context:
            - packagist
```
Be sure to configure `$CIRCLE_TOKEN` as an environment variable. To learn how to
create tokens, read [CircleCi's Documentation](https://circleci.com/docs/managing-api-tokens).
