FROM elixir:1.20.0-otp-29

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
