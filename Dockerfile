FROM elixir:1.20.3-otp-29

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
