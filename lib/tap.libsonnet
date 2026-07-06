local cond = import './cond.libsonnet';
local kc = import './kc.libsonnet';

// Accept an action as a keyspec string, an array of keyspec strings, or an
// array of to events as is.
local toEvents(action) =
  if std.isString(action) then
    kc.to(action)
  else if std.isArray(action) && std.length(action) > 0 && std.isString(action[0]) then
    kc.to(action)
  else
    action;

{
  // Mod-Tap manipulator: hold `key` for `hold` (a modifier sent lazily so
  // that a solo press emits nothing), tap it for `alone`.  `hold` defaults
  // to `key`, and any extra modifier is optional by default.  mixin, if
  // given, is merged into the manipulator; use it for extra fields like
  // conditions.  Field-level `+:` works there, e.g. { parameters+: ... }.
  modTap(key, alone, mixin=null, hold=null, optional='any', lazy=true, held_down_threshold_milliseconds=100)::
    local holdKey = if hold != null then hold else key;
    {
      type: 'basic',
      from: kc.from(key, optional=optional),
      to: kc.to(holdKey, lazy=lazy),
      to_if_alone: toEvents(alone),
      to_if_held_down: kc.to(holdKey),
      parameters: {
        'basic.to_if_held_down_threshold_milliseconds': held_down_threshold_milliseconds,
      },
    } + (if mixin == null then {} else mixin),

  // Deferred double tap support.
  //
  // withDoubleTap() takes a tap/hold manipulator and a double tap action, and
  // returns a manipulator pair that adds the double tap on top of it.  The
  // single tap action (to_if_alone if present, to otherwise) is deferred to
  // to_delayed_action, guarded by a variable armed on the single tap, so that
  // a double tap within window_milliseconds emits only the double tap action
  // without leaking the single tap one.  The deferred action fires on
  // timeout, or as soon as another key interrupts.
  //
  // The order of the generated manipulators and to events is significant:
  // the catcher must precede the base manipulator, and the armed events must
  // precede the disarm event because to event conditions are evaluated in
  // post order.
  withDoubleTap(manipulator, to, variable=null, window_milliseconds=300)::
    local v =
      if variable != null then
        variable
      else if std.objectHas(manipulator.from, 'key_code') then
        manipulator.from.key_code + '_tapped'
      else
        error 'withDoubleTap: give variable explicitly when from has no key_code';
    local armed = cond.eq(v, 1);
    local disarm = kc.to(set={ [v]: 0 });
    local hasAlone = std.objectHas(manipulator, 'to_if_alone');
    local fireIfArmed = std.map(
      function(event) event { conditions+: armed },
      if hasAlone then manipulator.to_if_alone else manipulator.to
    ) + disarm;
    [
      {
        type: 'basic',
        conditions: std.get(manipulator, 'conditions', []) + armed,
        from: manipulator.from,
        to: disarm + toEvents(to),
      },
      manipulator {
        [if hasAlone then 'to_if_alone' else 'to']: kc.to(set={ [v]: 1 }),
        to_delayed_action: {
          to_if_invoked: fireIfArmed,
          to_if_canceled: fireIfArmed,
        },
        parameters+: {
          'basic.to_delayed_action_delay_milliseconds': window_milliseconds,
        },
      },
    ],
}
