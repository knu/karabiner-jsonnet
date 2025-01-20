local cond = import './lib/cond.libsonnet';
local kc = import './lib/kc.libsonnet';
local device = {
  apple: {
    is_built_in_keyboard: true,
  },
  adv360_bt: {
    vendor_id: 7504,
    product_id: 24926,
  },
  adv360_usb: {
    vendor_id: 10730,
    product_id: 866,
  },
  group: {
    adv360: [
      $.adv360_bt,
      $.adv360_usb,
    ],
    programmable: self.adv360,
  },
};

{
  global: {
    check_for_updates_on_startup: true,
    show_in_menu_bar: true,
    show_profile_name_in_menu_bar: false,
    unsafe_ui: false,
  },
  profiles: [
    {
      complex_modifications: {
        parameters: {
          'basic.simultaneous_threshold_milliseconds': 50,
          'basic.to_delayed_action_delay_milliseconds': 500,
          'basic.to_if_alone_timeout_milliseconds': 200,
          'basic.to_if_held_down_threshold_milliseconds': 500,
          'mouse_motion_to_scroll.speed': 100,
        },
        rules: [
          {
            description: 'left_option to left_option/equal_sign on Apple keyboards',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_is(device.apple),
              } + o
              for o in [
                {
                  description: 'left_option to left_option/equal_sign',
                  from: kc.from('*loption'),
                  to: kc.to('loption', lazy=true),
                  to_if_alone: kc.to('='),
                  to_if_held_down: kc.to('loption'),
                  parameters: {
                    'basic.to_if_held_down_threshold_milliseconds': 100,
                  },
                },
              ]
            ],
          },
          {
            description: 'Tap Left Command to 英数',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_is_not(device.group.programmable),
                from: kc.from('*lcommand'),
                to: kc.to('lcommand', lazy=true),
                to_if_alone: kc.to('japanese_eisuu'),
                to_if_held_down: kc.to('lcommand'),
                parameters: {
                  'basic.to_if_held_down_threshold_milliseconds': 100,
                },
              },
            ],
          },
          {
            description: 'Tap Right Command to かな',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_is_not(device.group.programmable),
                from: kc.from('*rcommand'),
                to: kc.to('rcommand', lazy=true),
                to_if_alone: kc.to('japanese_kana'),
                to_if_held_down: kc.to('rcommand'),
                parameters: {
                  'basic.to_if_held_down_threshold_milliseconds': 100,
                },
              },
            ],
          },
          {
            description: 'left_shift & right_shift chords',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_is_not(device.group.programmable),
                from: kc.from(['rshift', 'lshift']) {
                  simultaneous_options: {
                    key_down_order: 'strict',
                    key_up_order: 'strict',
                  },
                },
                to: kc.to('S-`'),
                parameters: {
                  'basic.simultaneous_threshold_milliseconds': 200,
                },
              },
            ],
          },
          {
            description: 'left_shift to left_shift/grave_accent_and_tilde',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_is_not(device.group.programmable),
                from: kc.from('*lshift'),
                to: kc.to('lshift'),
                to_if_alone: kc.to('`'),
                to_if_held_down: kc.to('lshift'),
                parameters: {
                  'basic.to_if_held_down_threshold_milliseconds': 100,
                },
              },
            ],
          },
          {
            description: 'right_option to right_option/hyphen on Apple keyboards',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_is(device.apple),
                from: kc.from('*roption'),
                to: kc.to('roption', lazy=true),
                to_if_alone: kc.to('-'),
                to_if_held_down: kc.to('roption'),
                parameters: {
                  'basic.to_if_held_down_threshold_milliseconds': 100,
                },
              },
            ],
          },
          {
            description: 'right_shift to right_shift/backslash on Apple keyboards',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_is(device.apple),
                from: kc.from('*r shift'),
                to: kc.to('rshift'),
                to_if_alone: kc.to('\\'),
                to_if_held_down: kc.to('rshift'),
                parameters: {
                  'basic.to_if_held_down_threshold_milliseconds': 100,
                },
              },
            ],
          },
          {
            description: 'Fn with alphabet keys to Hyper',
            manipulators: [
              {
                type: 'basic',
                from: kc.from('fn-' + c),
                to: kc.to('LM-LA-LC-LS-' + c),
              }
              for c in std.stringChars('abcdefghijklmnopqrstuvwxyz')
            ],
          },
          {
            description: 'Touch cursor mode',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.eq('multitouch_extension_finger_count_total', 1),
              } + o
              for o in [
                { from: kc.from('*h'), to: kc.to('*left') },
                { from: kc.from('*j'), to: kc.to('*down') },
                { from: kc.from('*k'), to: kc.to('*up') },
                { from: kc.from('*l'), to: kc.to('*right') },
                { from: kc.from('*;'), to: kc.to('*RET') },
                { from: kc.from('*n'), to: kc.to('*home') },
                { from: kc.from('*m'), to: kc.to('*next') },
                { from: kc.from('*,'), to: kc.to('*prior') },
                { from: kc.from('*.'), to: kc.to('*end') },
                { from: kc.from('*/'), to: kc.to('*ESC') },
              ]
            ],
          },
        ],
      },
      devices: [
        // ...
        {
          // Apple Keyboards
          identifiers: { is_keyboard: true },
          simple_modifications: [
            kc.simple_from_to('`', 'ESC'),
            kc.simple_from_to('caps_lock', 'lcontrol'),
            kc.simple_from_to('lcontrol', '`'),
          ],
        },
      ],
      fn_function_keys: [
        kc.simple_from_to('f1', 'display_brightness_decrement'),
        kc.simple_from_to('f2', 'display_brightness_increment'),
        kc.simple_from_to('f3', 'mission_control'),
        kc.simple_from_to('f4', 'launchpad'),
        kc.simple_from_to('f5', 'illumination_decrement'),
        kc.simple_from_to('f6', 'illumination_increment'),
        kc.simple_from_to('f7', 'rewind'),
        kc.simple_from_to('f8', 'play_or_pause'),
        kc.simple_from_to('f9', 'fastforward'),
        kc.simple_from_to('f10', 'mute'),
        kc.simple_from_to('f11', 'volume_decrement'),
        kc.simple_from_to('f12', 'volume_increment'),
      ],
      name: 'Default',
      parameters: {
        delay_milliseconds_before_open_device: 1000,
      },
      selected: true,
      simple_modifications: [],
      virtual_hid_keyboard: {
        caps_lock_delay_milliseconds: 0,
        country_code: 0,
        indicate_sticky_modifier_keys_state: true,
        keyboard_type: 'ansi',
        mouse_key_xy_scale: 100,
      },
    },
  ],
}
