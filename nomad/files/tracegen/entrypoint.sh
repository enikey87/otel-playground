#!/bin/sh

# Set default command arguments
CMD_ARGS="tracegen -otlp-insecure -traces 1"

# If the OTEL_EXPORTER_OTLP_ENDPOINT environment variable is set, add the -otlp-endpoint flag
if [ -n "$OTEL_EXPORTER_OTLP_ENDPOINT" ]; then
    CMD_ARGS="$CMD_ARGS -otlp-endpoint $OTEL_EXPORTER_OTLP_ENDPOINT"
fi

# Execute the tracegen command with the constructed arguments
exec $CMD_ARGS
