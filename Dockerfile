FROM elixir:1.20.4-otp-29

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
