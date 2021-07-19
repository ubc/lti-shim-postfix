#!/bin/sh

# exit with error if command fails or using undefined var
set -euo pipefail

# mapping file to rewrite all "FROM" address to a no reply address
echo "/.+/  $POSTFIX_SENDER_NOREPLY" > /etc/postfix/sender_maps
postmap /etc/postfix/sender_maps

# envsubst does not complain about missing env vars, so we need to make sure
# that required env vars are present

# postgres credentials of the lti-shim database
export POSTGRES_PORT=${POSTGRES_PORT:-5432}
: ${POSTGRES_HOST:?}
: ${POSTGRES_DBNAME:?}
: ${POSTGRES_USERNAME:?}
: ${POSTGRES_PASSWORD:?}

# the lti-shim's email domain that's used for all our "fake" email addresses
: ${POSTFIX_RELAY_DOMAINS:?}
# servers that are allowed to send us email
: ${POSTFIX_MYNETWORKS:?}
# relay where we can redirect the email to the real user's email
: ${POSTFIX_RELAYHOST:?}

export POSTFIX_SASL_ENABLE=${POSTFIX_SASL_ENABLE:-no} 
if [ -n "$POSTFIX_SASL_PASSWORD" ]; then
    echo $POSTFIX_SASL_PASSWORD > /etc/postfix/sasl_passwd
    postmap /etc/postfix/sasl_passwd
fi

# fill in config templates with env vars
envsubst < /etc/postfix/dist/postgres_recipient.cf.dist > \
           /etc/postfix/postgres_recipient.cf
echo "postgres:"
cat /etc/postfix/postgres_recipient.cf
echo ""
echo ""

envsubst < /etc/postfix/dist/main.cf.dist > /etc/postfix/main.cf
echo "main:"
cat /etc/postfix/main.cf

exec "$@"
