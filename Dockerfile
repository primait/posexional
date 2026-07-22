FROM elixir:1.20.1-otp-29

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
