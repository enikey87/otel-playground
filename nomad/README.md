### Nomad cluster on localhost
Start a Nomad agent in developer mode
```shell
sudo nomad agent -dev -bind 0.0.0.0 -network-interface='{{ GetDefaultInterfaces | attr "name" }}'

# Caution: Avoid binding to 127.0.0.1 in container environments. 
# 'localhost' inside a container points to the container itself, not the host.
#
# Don't use this:
# sudo nomad agent -dev -bind 127.0.0.1
# sudo nomad agent -dev
```

### Collector sidecar

Start a Open Telemetry sidecar service.
```shell
nomad job run otel-collector-sidecar.nomad
```

### Tracegen job

To use the Dockerfile as a payload for a batch job in Nomad, you first need to build and push the Docker image to a container registry (like Docker Hub, Google Container Registry, or any other registry).

Once your image is in a registry, you can reference it in the Nomad job specification.

Build the Docker image
```shell
docker build -t gorecode/tracegen-job -f tracegen.Dockerfile .
```

Test the Docker image
```shell
docker run -it --rm --network host gorecode/tracegen-job
```

Push the Docker image
```shell
docker push gorecode/tracegen-job
```

Run the Docker image as Nomad job
```shell
nomad job run tracegen.nomad
```

### Nomad

- Tasks within a Group run together on the same machine.
- `local` path is filesystem that nomad creates for a task.
- Nomad’s default network is the Node network (physical network that your nodes are connected to). Each task group instance uses the Node IP network and gets its own port through dynamic port assignment. Since there is no Virtual IP or an additional overlay network required, the Nomad cluster network can be part of an existing enterprise network.


#### Videos

- [Open Telemetry demo (compose) to nomad](https://www.youtube.com/watch?v=Egk5L2AM-28)

#### Papers

- https://www.hashicorp.com/blog/a-kubernetes-user-s-guide-to-hashicorp-nomad
- https://www.hashicorp.com/blog/nomad-service-discovery
