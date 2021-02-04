[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # Posexional
    empty: :*,
    fixed_value: :*,
    guesser: 1,
    import_fields_from: 1,
    name: 1,
    progressive_number: :*,
    row: :*,
    separator: 1,
    value: :*,
    field: :*,

    # Formatter tests
    assert_format: 2,
    assert_format: 3,
    assert_same: 1,
    assert_same: 2,

    # Errors tests
    assert_eval_raise: 3
  ],
  inputs: ["lib/**/*.{ex,exs}", "test/**/*.{ex,exs}", "config/**/*.{ex,exs}"],
  line_length: 120
]
