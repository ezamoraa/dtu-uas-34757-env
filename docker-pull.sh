#!/bin/bash

VERSION=${VERSION:-`cat version`}
docker pull ezamoraa/dtu_uas_34757:$VERSION
