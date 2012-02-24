## Description

This is the API component of TV Ticker. It uses MobME's internal RPC component to serve requests.

## Install

Make sure config/database.yml and config/keys.yml are present. The keys used in this repository must be the same as the keys used for the client Android or jQTouch apps, otherwise the API would refuse to return requests.

$ bundle install --path vendor
$ bundle exec thin start
