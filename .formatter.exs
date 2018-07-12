[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # plug
    plug: :*,
    parse: :*,
    serialize: :*,
    value: :*,
    match: :*,

    # ecto
    has_one: :*,
    has_many: :*,
    embeds_one: :*,
    embeds_many: :*,
    belongs_to: :*,
    add: :*,
    from: :*,
    create: :*,
    drop: :*,

    # ecto migrations
    remove: 1,
    add: :*,
    execute: 1,
    create: 1,

    # phoenix
    transport: :*,
    socket: :*,
    pipe_through: :*,
    forward: :*,
    options: :*,
    defenum: :*,
    get: :*,
    post: :*,
    delete: :*,
    patch: :*,

    # absinthe
    field: :*,
    resolve: :*,
    arg: :*,
    list_of: :*,
    middleware: :*,

    # crash
    handle: :*
  ],
  line_length: 120
]
