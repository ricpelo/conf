#!/usr/bin/env bash

request="${1#*://}"                # Remove schema from url (atom:// or ide://)
request="${request#*?url=file://}" # Remove open?url=file://
request="${request//%2F//}"        # Replace %2F with /
request="${request/&line=/:}"      # Replace &line= with :
request="${request/&column=/:}"    # Replace &column= with :

if [ -n "$request" ]; then
    atom "$request"                # Launch Atom
fi
