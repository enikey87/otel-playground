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

      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }
    }
  }
}
