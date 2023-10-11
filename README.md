# otel-playground

Simple OTEL setup example with auth for Jaeger UI and Open Telemetry Collector.

Services:
- Jaeger in memory all in one. No ports exposed.
- Jaeger-UI behind nginx with basic auth. Exposes 16686 port.
- Open Telemetry Collector Gateway. Requires TLS + Auth for incoming telemetry. Exports incoming telemetry to Jaeger.
- Open Telemetry Collector Sidecar (Edge). Exports incoming telemetry to Collector Gateway. Don't require TLS or Auth for incoming data because it's running in trusted closed network like localhost.   

**Passwords**

- Jaeger UI: user:adidas
- Open Telemetry Collector gateway: otel-collector-edge:adidas

**Self-signed keys for TLS (insecure)**

TLS is required by client side of OTEL basic auth extension. So we have to turn it on. In local environment we could use following insecure exteremely dangerous (you've got the idea) snippet or do all your black magic with certs by yourself.
```shell
mkdir ssl
cd ssl
# enter password, I recommend: adidas
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
mv key.pem key.pem.backup
# extract unencrypted key
openssl rsa -passin pass:adidas -in key.pem.backup -out key.pem
# don't blame me, it's just a trash test cert
chmod o+r key.pem
```

### Papers

- https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/examples/demo
- https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/basicauthextension
- https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/bearertokenauthextension
- https://opentelemetry.io/ecosystem/registry/?component=extension
- https://github.com/open-telemetry/opentelemetry-collector/blob/main/config/configtls/README.md
- https://opentelemetry.io/blog/2022/otel-demo-app-nomad/
- https://opentelemetry.io/blog/2022/k8s-otel-expose/
- https://github.com/open-telemetry/opentelemetry-collector/blob/v0.58.0/config/configtls/README.md
- https://medium.com/opentelemetry/securing-your-opentelemetry-collector-1a4f9fa5bd6f