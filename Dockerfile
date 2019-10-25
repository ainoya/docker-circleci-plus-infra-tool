FROM hashicorp/terraform:0.11.11
ARG tfnotify_var=v0.3.0
ARG assume_role_var=0.3.2
ARG apex_var=1.0.0-rc3
RUN apk add curl
RUN curl -sL https://github.com/mercari/tfnotify/releases/download/${tfnotify_var}/tfnotify_${tfnotify_var}_linux_amd64.tar.gz  \
  | tar xz -C /tmp \
  && mv /tmp/tfnotify_${tfnotify_var}_linux_amd64/tfnotify /bin/
RUN curl -sL https://github.com/remind101/assume-role/releases/download/${assume_role_var}/assume-role-Linux -o /tmp/assume-role \
  && chmod +x /tmp/assume-role \
  && mv /tmp/assume-role /bin
RUN curl -sL https://github.com/apex/apex/releases/download/v${apex_var}/apex_${apex_var}_linux_amd64.tar.gz \
  | tar xz -C /tmp \
  && mv /tmp/apex /bin/
RUN curl -sL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/0.4.0-alpha.1/aws-iam-authenticator_0.4.0-alpha.1_linux_amd64 -o /tmp/aws-iam-authenticator \
  && chmod +x /tmp/aws-iam-authenticator \
  && mv /tmp/aws-iam-authenticator /bin
RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /tmp/kubectl \
  && chmod +x /tmp/kubectl \
  && mv /tmp/kubectl /bin
RUN curl -sSL https://github.com/shyiko/kubesec/releases/download/0.9.2/kubesec-0.9.2-linux-amd64 \
  -o kubesec && chmod +x kubesec && mv kubesec /bin/
RUN curl -sSL https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64 \
  -o kustomize && chmod +x kustomize && mv kustomize /bin/

FROM circleci/ruby:2.6.0-node
RUN sudo apt-get update && sudo apt-get install -y gcc make
WORKDIR /tmp
RUN curl -sSL http://www.gcd.org/sengoku/stone/stone-2.3e.tar.gz -o stone.tar.gz
RUN tar zxf stone.tar.gz && \
  cd stone-*/ && \
  FLAGS=-D_GNU_SOURCE make linux && chmod +x stone && \
  cp stone /tmp/stone
FROM circleci/ruby:2.6.0-node
COPY --from=0 /bin/terraform /bin
COPY --from=0 /bin/tfnotify /bin
COPY --from=0 /bin/assume-role /bin
COPY --from=0 /bin/apex /bin
COPY --from=0 /bin/aws-iam-authenticator /bin
COPY --from=0 /bin/kubectl /bin
COPY --from=0 /bin/kubesec /bin
COPY --from=0 /bin/kustomize /bin
COPY --from=1 /tmp/stone /bin
RUN sudo curl -sSL https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem -o /usr/share/ca-certificates/rds-ca-2019-root.pem
RUN sudo apt-get -y update \
  && sudo apt -y install mysql-client python-pip mysql-server \
  && pip install awscli mycli datadog
RUN curl -sSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb" \
  && sudo dpkg -i /tmp/session-manager-plugin.deb \
  && rm /tmp/session-manager-plugin.deb
COPY tools/do-exclusively.sh /bin
RUN sudo chmod +x /bin/do-exclusively.sh
ENV PATH $PATH:/home/circleci/.local/bin
RUN echo 'export PATH=$PATH:${HOME}/.local/bin' >> /home/circleci/.bashrc
