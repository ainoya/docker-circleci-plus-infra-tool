FROM hashicorp/terraform:0.11.11

FROM circleci/ruby:2.6.0
COPY --from=0 /bin/terraform /usr/local/bin/