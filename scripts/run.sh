#!/bin/bash

cp internal/buildinfo/buildinfo.go.in internal/buildinfo/buildinfo.go
go generate github.com/shokohsc/gohls/internal/api
go run *.go ${@:1}