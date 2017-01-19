#!/bin/bash

npm version patch
coffee --compile --output lib/ src/
git commit -a -m "$*"
git push
