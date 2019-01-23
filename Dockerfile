FROM hashicorp/terraform:0.11.11
ARG tfnotify_var=v0.3.0
RUN curl -sL https://github.com/mercari/tfnotify/releases/download/${tfnotify_var}/tfnotify_${tfnotify_var}_linux_amd64.tar.gz  \
  | tar xz -C /tmp \
  && mv /tmp/tfnotify_${tfnotify_var}_linux_amd64/tfnotify /bin/

FROM circleci/ruby:2.6.0
COPY --from=0 /bin/terraform /bin
COPY --from=0 /bin/tfnotify /bin