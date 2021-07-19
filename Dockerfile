FROM alpine:3.14

# - postfix with the postgres plugin so we can query lti-shim's database for
# fake to real email mapping
# - gettext is needed for envsubst, which replaces env vars in conf files for us
RUN apk add postfix postfix-pgsql gettext

# create the default alias lookup, or postfix will complain
RUN newaliases

# copy the config templates, entrypoint should fill them in with env vars
COPY postgres_recipient.cf.dist /etc/postfix/dist/postgres_recipient.cf.dist
COPY main.cf.dist /etc/postfix/dist/main.cf.dist

# we need a custom entrypoint to write postfix config from env vars, since
# postfix config files can't directly use env vars
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postfix", "start-fg"]
