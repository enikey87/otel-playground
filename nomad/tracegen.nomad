job "tracegen-batch-job" {
  datacenters = ["dc1"]
  type = "batch"

  meta {
    run_uuid = "${uuidv4()}" # force task to execute every time it's submitted to nomad
  }

  group "tracegen-group" {
    count = 1

    task "tracegen" {
      driver = "docker"

      config {
        image = "gorecode/tracegen-job:latest"
      }

      template {
        data        = <<EOH
{{ range service "otel-collector-sidecar-gRPC2" }}
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
