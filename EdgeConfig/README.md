# Creating / Changing Configuration

* Edit EdgeConfig/save_creds_example.coffee
* Run it with "coffee save_creds_example.coffee"
* Make sure the credentials.json and key.txt are on the production servers in ~/EdgeConfig

## Test credentials

There are two files in this folder that are created with:

    coffee save_creds_example.coffee

The "credentials.json" file connects to test servers on dev1.protovate.com

The "credentials_dev.json" file connects to servers on localhost without authentication.    Adding --dev on the command line will load this file automatically.