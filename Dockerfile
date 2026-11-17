FROM elixir:1.19.5-otp-27

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
