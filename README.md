# lti-shim-postfix

Build & push a Postfix docker image customized for the lti-shim.

The `entrypoint.sh` will customize Postfix config files to match the
environment variables.

Takes the following environment parameters:

We need to be able to connect to the lti-shim's database to map from fake
user's email to their real email.

* POSTGRES_HOST - lti-shim's postgres db host
* POSTGRES_PORT - defaults to postgres default port 5432
* POSTGRES_DBNAME - lti-shim's postgres db name
* POSTGRES_USERNAME - lti-shim's postgres db username
* POSTGRES_PASSWORDs - lti-shim's postgres db password

Postfix config for relaying:

* POSTFIX_SENDER_NOREPLY - we rewrite all "FROM" addresses to the given noreply address to prevent users from replying and unmasking themselves
* POSTFIX_RELAY_DOMAINS - lti-shim's email domain that's used for all our 'fake' email addresses
* POSTFIX_MYNETWORKS - servers that are allowed to send us email
* POSTFIX_RELAYHOST - server where we send the redirected email, it should then send it on to the user's real email

If SASL auth is needed for the relay server:

* POSTFIX_SASL_ENABLE - defaults to 'no', set to 'yes' to enable
* POSTFIX_SASL_PASSWORD - "$user $pass", will be written to a postfix lookup file 
