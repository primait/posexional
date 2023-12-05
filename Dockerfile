FROM public.ecr.aws/prima/elixir:1.14.2-5

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
