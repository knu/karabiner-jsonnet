local keyAliases = {
  "'": 'quote',
  ',': 'comma',
  '-': 'hyphen',
  '.': 'period',
  '/': 'slash',
  ';': 'semicolon',
  '=': 'equal_sign',
  '[': 'open_bracket',
  '\\': 'backslash',
  ']': 'close_bracket',
  '`': 'grave_accent_and_tilde',

  '!': 'S-1',
  '#': 'S-3',
  '$': 'S-4',
  '%': 'S-5',
  '&': 'S-7',
  '(': 'S-9',
  ')': 'S-0',
  '*': 'S-8',
  '+': 'S-=',
  ':': 'S-;',
  '<': 'S-,',
  '>': 'S-.',
  '?': 'S-/',
  '@': 'S-2',
  '"': "S-'",
  '^': 'S-6',
  _: 'S--',
  '{': 'S-[',
  '|': 'S-\\',
  '}': 'S-]',
  '~': 'S-`',

  S: 'shift',
  LS: 'left_shift',
  RS: 'right_shift',
  C: 'control',
  LC: 'left_control',
  RC: 'right_control',
  A: 'option',
  LA: 'left_option',
  RA: 'right_option',
  M::: 'command',
  LM: 'left_command',
  RM: 'right_command',

  lshift: 'left_shift',
  rshift: 'right_shift',
  lcontrol: 'left_control',
  rcontrol: 'right_control',
  loption: 'left_option',
  roption: 'right_option',
  lcommand: 'left_command',
  rcommand: 'right_command',

  ESC: 'escape',
  RET: 'return_or_enter',
  SPC: 'spacebar',
  TAB: 'tab',
  DEL: 'delete_or_backspace',

  backspace: 'delete_or_backspace',
  delete: 'delete_forward',

  up: 'up_arrow',
  down: 'down_arrow',
  left: 'left_arrow',
  right: 'right_arrow',
  prior: 'page_up',
  next: 'page_down',
  menu: 'application',
};

// Supported key specifications:
// - a
// - ESC
// - S-up
// - C-a
// - C-S-a
// - A-a
// - M-*a (`*` means any modifier is optional)

local toArray(value) =
  if std.isArray(value) then
    value
  else if value == null then
    []
  else
    [value];

local getKeyCode(key) =
  if std.objectHas(keyAliases, key) then
    keyAliases[key]
  else
    key;

local parseKeySpec(keyspec) =
  local len = std.length(keyspec);
  if keyspec[len - 1] == '-' then
    parseKeySpec(keyspec[0:len - 1] + keyAliases['-'])
  else (
    local keys = std.split(keyspec, '-');
    local nkeys = std.length(keys);
    local key = keys[nkeys - 1];
    local keyLen = std.length(key);
    std.map(
      getKeyCode,
      (
        if keyLen >= 2 && key[0] == '*' then
          ['any'] + keys[0:nkeys - 1] + parseKeySpec(key[1:])
        else if std.objectHas(keyAliases, key) then
          keys[0:nkeys - 1] + parseKeySpec(keyAliases[key])
        else
          keys
      )
    )
  );

local orderedModifiers =
  [
    'any',
    'fn',
    'caps_lock',
    'command',
    'option',
    'control',
    'shift',
    'left_command',
    'left_option',
    'left_control',
    'left_shift',
    'right_command',
    'right_option',
    'right_control',
    'right_shift',
  ];

local sortModifiers(mods) =
  std.sort(
    mods,
    function(mod)
      std.find(mod, orderedModifiers)[0]
  );

local generateKey(keyspec) =
  local keys = parseKeySpec(keyspec);
  local nkeys = std.length(keys);
  local mods = sortModifiers(keys[0:nkeys - 1]);
  local key = keys[nkeys - 1];
  std.foldr(
    function(mod, kc)
      kc { modifiers: [mod] + super.modifiers },
    mods,
    { key_code: key, modifiers: [] }
  );

local generateSetVariables(key_values) =
  if key_values != null then
    std.map(
      function(key)
        { set_variable: { name: key, value: key_values[key] } },
      std.objectFields(key_values)
    )
  else
    [];

local generateCommand(command) =
  if command != null then
    [{ shell_command: command }]
  else
    [];

local generateApplication(application) =
  if application != null then
    if std.startsWith(application, '/') then
      [{ software_function: { open_application: { file_path: application } } }]
    else
      [{ software_function: { open_application: { bundle_identifier: application } } }]
  else
    [];

local to(keys=null, set=null, command=null, application=null, lazy=null) =
  local events = std.prune(
    std.map(generateKey, toArray(keys)) + generateSetVariables(set) + generateCommand(command) + generateApplication(application)
  );
  if lazy == true then
    std.map(function(event) event { lazy: true }, events)
  else
    events;

local from(keyspec, mandatory=null, optional=null) =
  if std.isArray(keyspec) then
    local optionalMods = toArray(optional);
    {
      simultaneous: std.map(from, keyspec),
      modifiers: {
        mandatory: toArray(mandatory),
        optional: std.map(getKeyCode, optionalMods),
      },
    }
  else
    local key = generateKey(keyspec);
    local mods = toArray(std.get(key, 'modifiers'));
    local any = std.member(mods, 'any');
    local optionalMods = if any then ['any'] else toArray(optional);
    std.prune(
      key {
        modifiers: {
          mandatory: std.filter(function(mod) mod != 'any', mods),
          optional: std.map(getKeyCode, optionalMods),
        },
      }
    );

local simpleFromTo(keyspecFrom, keyspecTo) =
  local fromKeys = parseKeySpec(keyspecFrom);
  local fromKey = if std.length(fromKeys) == 1 then fromKeys[0] else error 'simple key expected';
  local toKeys = parseKeySpec(keyspecTo);
  local toKey = if std.length(toKeys) == 1 then toKeys[0] else error 'simple key expected';
  {
    from: { key_code: fromKey },
    to: [{ key_code: toKey }],
  };

{
  kbd(keyspec):: generateKey(keyspec),

  to(keys=null, set=null, command=null, application=null, lazy=null)::
    to(keys, set, command, application, lazy),

  from(keyspec, mandatory=null, optional=null)::
    from(keyspec, mandatory, optional),

  simple_from_to(simpleKeyFrom, simpleKeyTo)::
    simpleFromTo(simpleKeyFrom, simpleKeyTo),
}
