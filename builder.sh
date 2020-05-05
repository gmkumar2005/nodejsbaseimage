#!/usr/bin/env bash
(./ubuntu-baseimage.sh -v -r registry.container-registry:5000/ &&  
./ubuntu-nodeimage  -v -r registry.container-registry:5000/ -f registry.container-registry:5000/ubuntu-baseimage:latest && 
./node-baseimage -v -r registry.container-registry:5000/ -f registry.container-registry:5000/ubuntu-nodeimage:latest)