TAG ?= huskarorg/huskar-all-in-one:latest

build:
	docker build -t $(TAG) .
