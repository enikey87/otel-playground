job "tracing-backend" {
  datacenters = ["dc1"]
  namespace   = "default"
  type        = "service"

  group "jaeger-elasticsearch" {
    count = 1

    network {
      port "http" {
        to = 9200
      }

      port "transport" {
        to = 9300
      }
    }

    ephemeral_disk {
      size = 4096
    }

    task "jaeger-elasticsearch" {
      driver = "docker"

      config {
        image = "docker.elastic.co/elasticsearch/elasticsearch:7.17.14"
        ports = ["http", "transport"]
      }

      env = {
        "xpack.security.enabled" = "false",
        "discovery.type"         = "single-node",
        "path.data"              = "/alloc/data/",
        "path.logs"              = "/alloc/logs/"
      }

      resources {
        cpu    = 2000
        memory = 3000
      }

      service {
        name = "jaeger-elasticsearch"
        tags = ["elasticsearch"]
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

  group "tracing-backend" {
    count = 1

    network {
      port "jaeger-gRPC2" {
        to = 4317
      }
      port "jaeger-ui" {
        to = 16686
      }
      port "jaeger-ui-gateway" {
        to = 443
      }
      port "otel-collector-gateway-gRPC1" {
        to = 4318
      }
      port "otel-collector-gateway-gRPC2" {
        to = 4317
      }
      port "otel-collector-gateway-health" {
        to = 13133
      }
    }

    task "jaeger-all-in-one" {
      driver = "docker"

      config {
        image = "jaegertracing/all-in-one:latest"
        ports = ["jaeger-gRPC2", "jaeger-ui"]
      }

      template {
        data        = <<EOH
{{ range service "jaeger-elasticsearch" }}
ES_SERVER_URLS="http://{{ .Address }}:{{ .Port }}"
{{ else }}
ES_SERVER_URLS="http://127.0.0.1:65535"
{{ end }}
EOH
        destination = "local/service.env"
        env         = true
        change_mode = "restart"
      }

      env {
        SPAN_STORAGE_TYPE = "elasticsearch"
      }

      service {
        name     = "jaeger-gRPC2"
        port     = "jaeger-gRPC2"
      }

      service {
        name     = "jaeger-ui"
        port     = "jaeger-ui"
      }

      resources {
        cpu    = 800
        memory = 512
      }
    }

    task "jaeger-ui-gateway" {
      driver = "docker"

      config {
        image = "nginx:alpine"
        ports = ["jaeger-ui-gateway"]
        volumes = [
          "local/nginx.conf:/etc/nginx/nginx.conf",
          "local/nginx-htpasswd:/etc/nginx/htpasswd",
          "local/cert.pem:/etc/ssl/cert.pem",
          "local/key.pem:/etc/ssl/key.pem",
        ]
      }

      service {
        name     = "jaeger-ui-gateway"
        port     = "jaeger-ui-gateway"
      }

      template {
        data        = file("../ssl/cert.pem")
        destination = "local/cert.pem"
      }
      template {
        data        = file("../ssl/key.pem")
        destination = "local/key.pem"
      }
      template {
        data        = file("files/jaeger/nginx.conf")
        destination = "local/nginx.conf"
      }
      template {
        data        = <<EOH
{{ with secret "kv/data/jaeger-ui/auth" }}{{ .Data.data.username }}:{{ .Data.data.bcrypt_password }}{{ end }}
EOH
        destination = "local/nginx-htpasswd"
      }

      resources {
        cpu    = 800
        memory = 256
      }
    } // task

    task "otel-collector-gateway" {
      driver = "docker"

      config {
        image   = "otel/opentelemetry-collector-contrib:latest"
        ports   = [
          "otel-collector-gateway-gRPC1",
          "otel-collector-gateway-gRPC2",
          "otel-collector-gateway-health"
        ]
        args    = ["--config=/etc/collector-gateway-config.yaml"]
        volumes = [
          "local/otel/collector-gateway-config.yaml:/etc/collector-gateway-config.yaml",
          "local/cert.pem:/etc/ssl/cert.pem",
          "local/key.pem:/etc/ssl/key.pem",
        ]
      }

      template {
        data        = file("files/otel/collector-gateway-config.yaml")
        destination = "local/otel/collector-gateway-config.yaml"
      }
      template {
        data        = file("../ssl/cert.pem")
        destination = "local/cert.pem"
      }
      template {
        data        = file("../ssl/key.pem")
        destination = "local/key.pem"
      }

      service {
        name = "otel-collector-gateway-gRPC1"
        port = "otel-collector-gateway-gRPC1"
      }

      service {
        name = "otel-collector-gateway-gRPC2"
        port = "otel-collector-gateway-gRPC2"
      }

      service {
        name = "otel-collector-gateway-health"
        port = "otel-collector-gateway-health"
      }

      resources {
        cpu    = 800
        memory = 256
      }
    } // task
  } // group
} // job
