job "otel-backend" {
  datacenters = ["dc1"]
  namespace = "default"
  type = "service"

  group "otel-backend" {
    count = 1

    network {
      mode = "host"

      port "gRPC1" {
        to = 4318
      }
      port "gRPC2" {
        to = 4317
      }
    }

    task "otel-collector-gateway" {
      driver = "docker"

      config {
        image   = "otel/opentelemetry-collector-contrib:latest"
        ports   = ["gRPC1", "gRPC2"]
        args    = ["--config=/etc/collector-gateway-config.yaml"]
        volumes = ["local/otel/collector-gateway-config.yaml:/etc/collector-gateway-config.yaml"]
      }

      template {
        data        = file("files/otel/collector-gateway-config.yaml")
        destination = "local/otel/collector-gateway-config.yaml"
      }

      service {
        name = "otel-collector-gateway-gRPC1"
        port = "gRPC1"
        provider = "nomad"
      }

      service {
        name = "otel-collector-gateway-gRPC2"
        port = "gRPC2"
        provider = "nomad"
      }
    } // task
  } // group
} // job
