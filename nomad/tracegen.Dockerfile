# Start with the official Go image.
FROM golang:1.17-alpine as builder

# Install git, which is required for fetching Go packages.
RUN apk add --no-cache git

# Install tracegen utility.
RUN go install github.com/open-telemetry/opentelemetry-collector-contrib/tracegen@latest

# Use a lightweight alpine image for the final image.
FROM alpine:latest

# Copy the tracegen binary from the builder image.
COPY --from=builder /go/bin/tracegen /usr/local/bin/tracegen

# Copy the entrypoint script.
COPY files/tracegen/entrypoint.sh /entrypoint.sh

# Use the entrypoint script to start the container.
ENTRYPOINT ["/entrypoint.sh"]
