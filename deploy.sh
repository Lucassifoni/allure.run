#!/bin/bash
DATETIME=$(date "+%Y-%m-%d %H:%M:%S")
git add .
git commit -m "last build $DATETIME"
git push origin
