FROM elixir:1.6

RUN apt-get update && apt-get install -qqy unzip \
                     libncurses5 \
                     groff \
                     less \
                     curl \
                     tar \
                     gzip \
                     vim \
                     tzdata && \
    cp /usr/share/zoneinfo/UTC /etc/localtime && \
    echo "Etc/UTC" > /etc/timezone && \
    apt-get purge -y unzip \
                    wget && \
    rm -r /var/lib/apt/lists/*

WORKDIR /code
RUN mix local.hex --force
RUN mix local.rebar --force

ENTRYPOINT ["/code/entrypoint"]
