FROM alpine:latest

RUN apk add --no-cache git make musl-dev go

RUN cd / && git clone https://github.com/labyrinthinesecurity/kubewatch.git

ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin
RUN cd /kubewatch && go install
