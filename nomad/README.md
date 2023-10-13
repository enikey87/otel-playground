### Nomad cluster on localhost
Start a Nomad agent in developer mode and bind it to localhost
```shell
sudo nomad agent -dev -bind 127.0.0.1
```

### Tracegen job

To use the Dockerfile as a payload for a batch job in Nomad, you first need to build and push the Docker image to a container registry (like Docker Hub, Google Container Registry, or any other registry). Once your image is in a registry, you can reference it in the Nomad job specification.

Start OTEL service set
```shell
# execute in root otel-playground repo folder in other terminal
docker-compose up
```
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