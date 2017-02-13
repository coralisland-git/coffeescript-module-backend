#!/bin/bash

npm version patch --force
coffee --map --compile --output lib/ src/*coffee
git add lib/*js lib/*map
git commit -a -m "$*"
git push
