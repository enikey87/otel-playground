job "otel-collector-sidecar" {
  datacenters = ["dc1"]
  namespace = "default"
  type = "service"

  group "otel-collector-sidecar" {
    count = 1

    network {
      mode = "host"

      port "gRPC1" {
        to = 4318
        static = 4318
      }
      port "gRPC2" {
        to = 4317
        static = 4317
      }
    }

    task "otel-collector-sidecar" {
      driver = "docker"

      config {
        image   = "otel/opentelemetry-collector-contrib:latest"
        ports   = ["gRPC1", "gRPC2"]
        args    = ["--config=/etc/collector-sidecar-config.yaml"]
        volumes = ["local/otel/collector-sidecar-config.yaml:/etc/collector-sidecar-config.yaml"]
      }

      template {
        data        = file("files/otel/collector-sidecar-config.yaml")
        destination = "local/otel/collector-sidecar-config.yaml"
      }

      service {
        name = "otel-collector-sidecar-gRPC1"
        port = "gRPC1"
        provider = "nomad"
      }

      service {
        name = "otel-collector-sidecar-gRPC2"
        port = "gRPC2"
        provider = "nomad"
      }
    } // task
  } // group
} // job
