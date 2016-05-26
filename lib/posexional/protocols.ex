defprotocol Posexional.Protocol.FieldLength do
  @doc "returns the field lenght"
  def length(field)
end

defprotocol Posexional.Protocol.FieldName do
  @doc "returns the field name"
  def name(field)
end

defprotocol Posexional.Protocol.FieldOutput do
  @doc "returns the field name"
  def output(field, binary)
end
