FROM golang:1.19.0-alpine3.16 AS buildando
WORKDIR /app
COPY . /app
RUN go mod init exporter.go
RUN go mod tidy
RUN go build exporter.go

FROM alpine:3.16
copy --from=buildando /app/exporter /app/exporter
EXPOSE 7788
WORKDIR /app
CMD ["./exporter"]

