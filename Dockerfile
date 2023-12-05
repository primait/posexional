FROM elixir:1.14.5-otp-25

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
