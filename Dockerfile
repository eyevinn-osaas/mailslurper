FROM golang:1.23.4-alpine as builder

LABEL maintainer="erguotou525@gmail.compute"

RUN apk --no-cache add git libc-dev gcc
RUN go install github.com/mjibson/esc@latest # TODO: Consider using native file embedding

COPY . /go/src/github.com/mailslurper/mailslurper
WORKDIR /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper

RUN go get
RUN go generate
RUN go build

FROM alpine:3.15

RUN apk add --no-cache nginx
RUN apk add --no-cache ca-certificates \
 && echo -e '{\n\
  "wwwAddress": "0.0.0.0",\n\
  "wwwPort": 8080,\n\
  "wwwPublicURL": "",\n\
  "serviceAddress": "0.0.0.0",\n\
  "servicePort": 8085,\n\
  "servicePublicURL": "",\n\
  "smtpAddress": "0.0.0.0",\n\
  "smtpPort": 2500,\n\
  "dbEngine": "SQLite",\n\
  "dbHost": "",\n\
  "dbPort": 0,\n\
  "dbDatabase": "./mailslurper.db",\n\
  "dbUserName": "",\n\
  "dbPassword": "",\n\
  "maxWorkers": 1000,\n\
  "autoStartBrowser": false,\n\
  "keyFile": "",\n\
  "certFile": "",\n\
  "adminKeyFile": "",\n\
  "adminCertFile": ""\n\
  }'\
  >> config.json

COPY --from=builder /go/src/github.com/mailslurper/mailslurper/cmd/mailslurper/mailslurper mailslurper

COPY --from=builder /go/src/github.com/mailslurper/mailslurper/nginx.conf /etc/nginx/http.d/default.conf
COPY --from=builder /go/src/github.com/mailslurper/mailslurper/entrypoint.sh entrypoint.sh
RUN chmod +x ./entrypoint.sh
EXPOSE 8080 2500

ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
