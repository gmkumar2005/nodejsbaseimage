#!/usr/bin/env bash
set -o errexit
set -x
buildcntr2=$(buildah from node:10.20.1-alpine3.11)
buildah config --label maintainer="Kiran Kumar <gmkumar2005@gmail.com>" $buildcntr2
# buildmnt1=$(buildah mount $buildcntr)
buildah config --user root $buildcntr2
buildah run $buildcntr2 apk --no-cache add  supervisor curl nginx 

# Configure supervisord
# COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
buildah copy $buildcntr2 supervisord.conf /etc/supervisor/conf.d/supervisord.conf
buildah run $buildcntr2 mkdir /app
buildah copy $buildcntr2 . /app
buildah config --workingdir /app  $buildcntr2
buildah config --env NG_CLI_ANALYTICS=ci $buildcntr2 

buildah config --env PATH=/app/node_modules/.bin:$PATH $buildcntr2
# buildah run $buildcntr2  adduser   --disabled-password  --gecos ""    --ingroup "nobody"   --no-create-home  --uid "1111"  "nobody"

buildah run $buildcntr2 -- yarn install  --silent --non-interactive   
buildah run $buildcntr2 -- yarn --silent --non-interactive global add @angular/cli 
buildah run $buildcntr2 -- pwd 
buildah run $buildcntr2 -- ls node_modules 
buildah run $buildcntr2 -- ng build --output-path=/var/www/html

buildah run $buildcntr2 -- yarn cache clean --silent --non-interactive

# Remove default server definition
buildah run $buildcntr2 rm /etc/nginx/conf.d/default.conf
buildah run $buildcntr2 rm /etc/nginx/nginx.conf

# Configure nginx
buildah copy $buildcntr2  nginx.conf /etc/nginx/nginx.conf

buildah run $buildcntr2 sh -c "chown -R nobody:nobody  /var/www/html" 
buildah run $buildcntr2 sh -c "chown -R nobody:nobody  /app" 
buildah run $buildcntr2 sh -c "chown -R nobody:nobody  /var/lib/nginx" 
buildah run $buildcntr2 sh -c "chown -R nobody:nobody  /var/log/nginx" 
buildah run $buildcntr2 sh -c "chown -R nobody:nobody  /run" 



buildah config --cmd '/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' $buildcntr2 

buildah config --user nobody:nobody $buildcntr2 
buildah config --port 8080 $buildcntr2 
buildah config --workingdir /var/www/html  $buildcntr2
buildah commit --squash --rm --format docker $buildcntr2 localhost:32000/node-basebuild:latest
echo "Usage : - podman run -p 8080:8080 -d -i -t localhost:32000/node-basebuild -name node-basebuild"

