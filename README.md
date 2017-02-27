# README

A tool for a digital marketing agency to view and download all metrics from the
platforms they are running their clients campaigns on.

## Software dependencies

* Ruby 2.4.0
* PostgreSQL

## Setting up

You'll need to get some sensitive credentials from another developer, including:

 - A Facebook access token (`FACEBOOK_ACCESS_TOKEN`).
 - Google client secrets (`GOOGLE_CLIENT_SECRETS`).


```bash
$ bin/setup
```

## Running

```bash
$ foreman start
```

### Useful links for working with the APIs & SDKs

* [This comment on a gist](https://gist.github.com/joost/5344705#gistcomment-1982619) gives an example of making a batch_get_reports request from the Google Analytics API
* There's also [a Query Explorer for Google APIs](https://ga-dev-tools.appspot.com/query-explorer/)!
