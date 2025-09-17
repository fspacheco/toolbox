#!/bin/sh

NAME=dev

podman build --squash --tag $NAME-toolbox:latest Container/
toolbox create -i $NAME-toolbox:latest $NAME
toolbox run --container=$NAME setup_extensions.sh
