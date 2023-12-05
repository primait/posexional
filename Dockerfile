FROM public.ecr.aws/prima/elixir:1.15.7

WORKDIR /code

ENTRYPOINT ["/code/entrypoint"]
