#!/bin/bash

npm version minor --force
coffee --map --compile --output lib/ src/*coffee
git add lib/*js lib/*map
git commit -a -m "$*"
git push
