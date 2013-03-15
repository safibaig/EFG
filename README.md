EFG
===

[![Build Status](https://travis-ci.org/alphagov/EFG.png?branch=master)](https://travis-ci.org/alphagov/EFG)

Enterprise Finance Guarantee

## Getting started

You will need MySQL and may have to create an app-specific MySQL user - check `config/database.yml` for user details.

    bundle install
    rake db:create
    rake db:reset
    rake spec

To run the tests, you will need a number of efg_test databases, since we are now running the tests using the parallel gem. In the dev VM and CI environment, this should Just Work. Outside of these environments, you may need to explicitly create a number of efg_test{NUMBER} instances with appropriate user account and permissions.
