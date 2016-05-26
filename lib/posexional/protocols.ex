defprotocol Posexional.Protocol.FieldLength do
  @doc "returns the field lenght"
  def length(field)
end

defprotocol Posexional.Protocol.FieldName do
  @doc "returns the field name"
  def name(field)
end

defprotocol Posexional.Protocol.FieldWrite do
  @doc "returns the field to be inserted in the positional file"
  def write(field, binary)
end

defprotocol Posexional.Protocol.FieldRead do
  @doc "returns the value of a field, given it's positional representation"
  def read(field, content)
end
