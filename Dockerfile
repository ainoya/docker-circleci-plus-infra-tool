FROM hashicorp/terraform:0.11.11
ARG tfnotify_var=v0.3.0
ARG assume_role_var=0.3.2
ARG apex_var=1.0.0-rc3
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


FROM circleci/ruby:2.6.0-node
COPY --from=0 /bin/terraform /bin
COPY --from=0 /bin/tfnotify /bin
COPY --from=0 /bin/assume-role /bin
COPY --from=0 /bin/apex /bin
COPY --from=0 /bin/aws-iam-authenticator /bin
COPY --from=0 /bin/kubectl /bin
RUN sudo apt -y install python-pip \
  && pip install awscli
RUN echo 'export PATH=$PATH:${HOME}/.local/bin' >> /home/circleci/.bashrc