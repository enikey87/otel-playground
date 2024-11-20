### Nomad cluster on localhost

**!!NOT SURE IF THIS IS ACTUAL!!**

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

or use [Hashiqube](https://hashiqube.com/#/)
```
sudo apt-get install virtualbox
# original https://github.com/star3am/hashiqube.git has no nomad/vault integration out of box
git clone https://github.com/avillela/hashiqube.git
cd hashiqube
git checkout main
# it can take 15 - 30 minutes
vagrant up
```

### Vault

Setup access to vault running in Hashiqube ([details](https://github.com/avillela/hashiqube#vault-setup))
```shell
vagrant ssh
# from vagrant
cat /etc/vault/init.file | grep Root | rev | cut -d' ' -f1 | rev > /vagrant/hashicorp/token.txt
# you can you this token to login from http://localhost:8200 on host
cat /vagrant/hashicorp/token.txt
# from host
export VAULT_TOKEN=$(cat hashicorp/token.txt) && \
rm hashicorp/token.txt
export VAULT_ADDR=http://localhost:8200
```

Put secrets into Vault
```shell
# user:adidas for jaeger-ui
vault kv put kv/jaeger-ui/auth username="user" bcrypt_password="\$apr1\$h.yv.W30\$X0QI1mK8WU6GeY..iCFcj/"
# secret token to access collector-gateway from outside
vault kv put kv/otel-collector-gateway/auth token="NRNZaAItflRjZZyLqtNnBgubyjgmLShLlAehqileeMromhzjhLNxuoIauWnbKmxbOObathqLGqUFbNqfKKxicEfSyBicvvgjHWHgCkkjeFwmKJFrXWTrJhtWusjgHAangUSZsbDQEAvXPxXZqPWCMSmokqoJDyuslVUtUvFPuMVcgmPCzHXNVArwJMUlaBhxFjfWGJnTUmcQWMzTidAbmHgxhsRzolEawgGZXkcjwYKUhPQbshTfeuwUyRAXelJO"
# ensure that token can be read
vault kv get "kv/otel-collector-gateway/auth"
```

### Collector sidecar (deamonset)

Start Open Telemetry sidecar service.
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

- https://adri-v.medium.com/list/hashiqube-bfdcb9c84e10
- https://adri-v.medium.com/just-in-time-nomad-configuring-hashicorp-nomad-vault-integration-on-hashiqube-388c14cb070a
- https://www.hashicorp.com/blog/a-kubernetes-user-s-guide-to-hashicorp-nomad
- https://www.hashicorp.com/blog/nomad-service-discovery
- https://github.com/avillela/hashiqube#quickstart
- https://storiesfromtheherd.com/just-in-time-nomad-running-the-opentelemetry-collector-on-hashicorp-nomad-with-hashiqube-4eaf009b8382