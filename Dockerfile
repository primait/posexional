FROM elixir:1.16-otp-25

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
