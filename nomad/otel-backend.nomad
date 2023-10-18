job "tracing-backend" {
  datacenters = ["dc1"]
  namespace = "default"
  type = "service"

  group "jaeger" {
    count = 1

    network {
      port "gRPC2" {
        to = 4317
      }
      port "jaeger-ui" {
        to = 16686
      }
    }

    task "jaeger-all-in-one" {
      driver = "docker"

      config {
        image = "jaegertracing/all-in-one:latest"
        ports = ["gRPC2", "jaeger-ui"]
      }

      service {
        name = "jaeger-backend-gRPC2"
        port = "gRPC2"
        provider = "nomad"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }
    }
  }

  // FIXME: can't figure out how to bind OTEL collector to jaeger in single group because they have conflicting ports
  group "otel-backend" {
    count = 1

    network {
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

      resources {
        cpu    = 1000
        memory = 512
      }
    } // task
  } // group
} // job
