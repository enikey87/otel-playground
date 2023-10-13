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

# Set the command to run tracegen with the specified arguments when the container starts.
CMD ["tracegen", "-otlp-insecure", "-traces", "1"]
