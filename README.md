# README

A tool for a digital marketing agency to view and download all metrics from the platforms they are running their clients campaigns on.

## Dependencies

* Ruby 2.4.0

## Running the app

```
$bundle
$bin/rake db:create db:migrate db:seed
$foreman start
```

### Useful links for working with the APIs & SDKs

* [This comment on a gist](https://gist.github.com/joost/5344705#gistcomment-1982619) gives an example of making a batch_get_reports request from the Google Analytics API