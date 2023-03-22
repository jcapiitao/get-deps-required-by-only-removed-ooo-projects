#!/bin/bash
podman build -t tripleo-deps:local -f Containerfile
podman run -v .:/workdir:Z -w /workdir -it --rm localhost/tripleo-deps:local
