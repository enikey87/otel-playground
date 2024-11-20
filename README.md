# OpenTelemetry Server Setup

This repository provides two implementations of a local OpenTelemetry server to collect, process, and visualize telemetry data.

It includes the following components:
- **Jaeger**: For visualizing and exploring traces. https://localhost:16686/
- **OpenTelemetry Collector Sidecar**: For collecting and exporting telemetry data to `OpenTelemetry Collector Gateway`. http://localhost:4318
- **OpenTelemetry Collector Gateway**: For receiving telemetry from clients and exporting to `Jaeger`.
- **Nginx**: To proxy traffic and expose endpoints securely.

The server can be deployed on localhost using:
- [Docker Compose](compose/)
- [Nomad](nomad/)
