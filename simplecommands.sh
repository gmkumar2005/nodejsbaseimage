# Project setup 
    oc login https://console.nexgen.parkar.consulting
    oc new-project barcodev --description="Barcodev dev" --display-name="Barcodev-dev"
    oc project barcodev

# Sample
oc import-image node:10.20.1-alpine3.11  --confirm -n barcodev 

oc new-build --name=barcodev-basebuild --strategy docker --image-stream=node:10.20.1-alpine3.11 --binary=true -n barcodev
oc start-build barcodev-basebuild --from-dir=. --follow -n barcodev
oc new-app barcodev-basebuild:latest --allow-missing-images --name=barcodevbase  -n barcodev
oc set triggers dc -l barcodevbase --containers=barcodevbase --from-image=barcodev-basebuild:latest --manual -n barcodev
oc expose svc/barcodevbase -n barcodev

# NodeJS Base
    oc import-image node:10.20.1-alpine3.11  --confirm -n barcodev 
    oc new-build --name=node-basebuild --strategy docker --image-stream=node:10.20.1-alpine3.11 --from-repo=https://github.com/parkarteam/nodejsbaseimage.git -n barcodev

    oc new-build --name=node-basebuild node:10.20.1-alpine3.11~https://github.com/parkarteam/nodejsbaseimage.git --strategy docker -n barcodev
    oc start-build node-basebuild  --follow -n barcodev
# verify Base
oc new-app node-basebuild:latest --allow-missing-images --name=nodebase  -n barcodev
oc set triggers dc -l nodebase --containers=nodebase --from-image=node-basebuild:latest --manual -n barcodev
oc expose svc/nodebase -n barcodev

# Suitecrm APP
    oc new-build --name=suitecrmdev-build --strategy docker --image-stream=suitecrmdev-basebuild --binary=true --env=SUITECRM_RELEASE_URL=https://github.com/salesagility/SuiteCRM/archive/v7.11.13.tar.gz -n suitecrmdev
    oc start-build suitecrmdev-build --from-dir=suitecrmimage --follow -n suitecrmdev
    oc new-app suitecrmdev-build:latest --allow-missing-images --name=suitecrm  -n suitecrmdev
    
    oc set triggers dc -l suitecrm --containers=suitecrm --from-image=lsuitecrmdev-build:latest --manual -n suitecrmdev
    # oc rollout cancel dc/leantime-app -n leantimedev
    oc expose svc/suitecrm -n suitecrmdev
# deploy mysql 
    oc new-app --name=mysqlsuitecrm -e MYSQL_USER=suitecrm   -e MYSQL_PASSWORD=suitecrm -e MYSQL_DATABASE=suitecrm  docker.io/centos/mysql-57-centos7:latest -n suitecrmdev
oc new-app --name=mysqlsuitecrm2 -e MYSQL_DATABASE=suitecrm  docker.io/centos/mysql-57-centos7:latest  -n suitecrmdev

oc set env dc/mysqlsuitecrm2 --from=secret/suitecrmdev-secret  -n suitecrmdev

--from=secret/suitecrmdev-secret