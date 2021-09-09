FROM hashicorp/terraform:1.0.1
ARG evans_ver=0.10.0
RUN apk add curl
RUN curl -sL https://github.com/ktr0731/evans/releases/download/${evans_ver}/evans_linux_amd64.tar.gz \
  | tar xz -C /tmp \
  && mv /tmp/evans /bin/
FROM envoyproxy/envoy:v1.19.1
COPY --from=0 /bin/evans /bin
