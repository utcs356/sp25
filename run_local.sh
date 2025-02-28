#!/bin/sh
export JEKYLL_VERSION=4
docker run  --platform linux/amd64 --rm \
  --volume="$PWD:/srv/jekyll:Z" \
  -p 8080:4000 jekyll/builder:$JEKYLL_VERSION \
  jekyll serve