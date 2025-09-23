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

local app_cond(type, regexes, description=null) =
  local regexArray = toArray(regexes);
  local withSlash = std.filter(function(regex) std.member(regex, '/'), regexArray);
  local withoutSlash = std.filter(function(regex) !std.member(regex, '/'), regexArray);
  [
    std.prune(
      {
        description: description,
        bundle_identifiers: withoutSlash,
        file_paths: withSlash,
        type: type,
      }
    ),
  ];

{
  eq(name, value)::
    [{ name: name, type: 'variable_if', value: value }],

  ne(name, value)::
    [{ name: name, type: 'variable_unless', value: value }],

  device_is(identifiers, description=null):: device_cond('device_if', identifiers, description),
  device_is_not(identifiers, description=null):: device_cond('device_unless', identifiers, description),
  device_exists(identifiers, description=null):: device_cond('device_exists_if', identifiers, description),
  device_does_not_exist(identifiers, description=null):: device_cond('device_exists_unless', identifiers, description),

  app_is(regexes, description=null):: app_cond('frontmost_application_if', regexes, description),
  app_is_not(regexes, description=null):: app_cond('frontmost_application_unless', regexes, description),
}
