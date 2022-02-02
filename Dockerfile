FROM golang:1.17 as builder

WORKDIR /app

COPY . /app

RUN CGO_ENABLED=0 go build -v -o notify-telegram .

FROM alpine:3.15.0

COPY --from=builder /app/notify-telegram /notify-telegram

ENTRYPOINT ["/notify-telegram"]
