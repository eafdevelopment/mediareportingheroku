# README

A tool for a digital marketing agency to view and download all metrics from the platforms they are running their clients campaigns on.

## Software dependencies

* Ruby 2.4.0
* PostgreSQL

## Setting up

To clone the respository:

```bash
$ cd ~
$ git clone git@github.com:no-mayo/eight_and_four.git
$ cd eight_and_four
```

You'll then need to get some sensitive credentials from another developer for your `.env` file, including:

 - Facebook access token (`FACEBOOK_ACCESS_TOKEN`)
 - Google Analytics client secrets (`GOOGLE_CLIENT_SECRETS`)
 - Google AdWords token & secrets (`ADWORDS_DEVELOPER_TOKEN`, `ADWORDS_OAUTH2_CLIENT_ID`, `ADWORDS_OAUTH2_CLIENT_SECRET`)
 - Twitter tokens and secrets (`TWITTER_ACCESS_TOKEN`, `TWITTER_ACCESS_TOKEN_SECRET`, `TWITTER_CONSUMER_KEY`, `TWITTER_CONSUMER_SECRET`)

Then you can run:

```bash
$ bin/setup
```

## To run the app

```bash
$ foreman start
```

## Running tests

```bash
$ rspec
```

### Deployment

Run the tests first. Then:

```bash
$ git add .
$ git commit -m "Commit message here"
$ git push heroku master
```

### Useful links for working with the APIs & SDKs

* [This comment on a gist](https://gist.github.com/joost/5344705#gistcomment-1982619) gives an example of making a batch_get_reports request from the Google Analytics API
* There's also [a Query Explorer for Google Analytics](https://ga-dev-tools.appspot.com/query-explorer/)
