local toArray(value) =
  if std.isArray(value) then
    value
  else if value == null then
    []
  else
    [value];

local device_cond(type, identifiers, description=null) =
  [
    std.prune(
      {
        description: description,
        identifiers: toArray(identifiers),
        type: type,
      }
    ),
  ];

{
  eq(name, value)::
    [{ name: name, type: 'variable_if', value: value }],

  ne(name, value)::
    [{ name: name, type: 'variable_unless', value: value }],

  device_if(identifiers, description=null):: device_cond('device_if', identifiers, description),
  device_unless(identifiers, description=null):: device_cond('device_unless', identifiers, description),
  device_exists_if(identifiers, description=null):: device_cond('device_exists_if', identifiers, description),
  device_exists_unless(identifiers, description=null):: device_cond('device_exists_unless', identifiers, description),
}
