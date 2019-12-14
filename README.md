# huskar-all-in-one

An all-in-one Docker image for Huskar Demo.


## Usage

```
docker run -d --name huskar-all-in-one -p 8080:80 huskarorg/huskar-all-in-one:latest

or

docker run -d --name huskar-all-in-one -p 8080:80 dockerhub.azk8s.cn/huskarorg/huskar-all-in-one:latest
```

Visit http://127.0.0.1:8080 .

P.S. You can login the console with username `huskar` and password `test` .


## Build

```
TAG=huskarorg/huskar-all-in-one:v0.1.0 make
```
