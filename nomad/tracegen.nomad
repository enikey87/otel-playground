job "tracegen-batch-job" {
  datacenters = ["dc1"]
  type = "batch"

  group "tracegen-group" {
    count = 1

    task "tracegen" {
      driver = "docker"

      config {
        image = "gorecode/tracegen-job:latest"
      }

      # FIXME: it's not affecting anything because tracegen utility doesn't respect OTEL_EXPORTER_OTLP_ENDPOINT
      template {
        data        = <<EOH
{{ range nomadService "otel-collector-sidecar-gRPC2" }}
OTEL_EXPORTER_OTLP_ENDPOINT="{{ .Address }}:{{ .Port }}"
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }

      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }
    }
  }
}
