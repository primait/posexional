FROM msaraiva/elixir-dev:1.2.4

#RUN sed -i -e 's/v3\.3/edge/g' /etc/apk/repositories
RUN apk -Uuv add erlang-xmerl mysql-client git openssh-client \
    groff less python py-pip && \
    pip install awscli && \
    apk --purge -v del py-pip && \
    rm -rf /var/cache/apk/*

WORKDIR /code
RUN mix local.hex --force
RUN mix local.rebar --force

ENTRYPOINT ["/code/entrypoint"]
