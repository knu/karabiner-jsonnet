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
            description: 'grave/caps_lock/left_control/left_option to escape/left_control/grave/half-equal on Apple keyboards',
            manipulators: [
              {
                type: 'basic',
                conditions: cond.device_if(device.apple),
              } + o
              for o in [
                {
                  from: kc.from('*`'),
                  to: kc.to('ESC'),
                },
                {
                  from: kc.from('*caps_lock'),
                  to: kc.to('lcontrol'),
                },
                {
                  from: kc.from('*lcontrol'),
                  to: kc.to('`'),
                },
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
                conditions: cond.device_unless(device.group.programmable),
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
                conditions: cond.device_unless(device.group.programmable),
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
                conditions: cond.device_unless(device.group.programmable),
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
                conditions: cond.device_unless(device.group.programmable),
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
                conditions: cond.device_if(device.apple),
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
                conditions: cond.device_if(device.apple),
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
      ],
      fn_function_keys: [
        {
          from: {
            key_code: 'f1',
          },
          to: [
            {
              key_code: 'display_brightness_decrement',
            },
          ],
        },
        {
          from: {
            key_code: 'f2',
          },
          to: [
            {
              key_code: 'display_brightness_increment',
            },
          ],
        },
        {
          from: {
            key_code: 'f3',
          },
          to: [
            {
              key_code: 'mission_control',
            },
          ],
        },
        {
          from: {
            key_code: 'f4',
          },
          to: [
            {
              key_code: 'launchpad',
            },
          ],
        },
        {
          from: {
            key_code: 'f5',
          },
          to: [
            {
              key_code: 'illumination_decrement',
            },
          ],
        },
        {
          from: {
            key_code: 'f6',
          },
          to: [
            {
              key_code: 'illumination_increment',
            },
          ],
        },
        {
          from: {
            key_code: 'f7',
          },
          to: [
            {
              key_code: 'rewind',
            },
          ],
        },
        {
          from: {
            key_code: 'f8',
          },
          to: [
            {
              key_code: 'play_or_pause',
            },
          ],
        },
        {
          from: {
            key_code: 'f9',
          },
          to: [
            {
              key_code: 'fastforward',
            },
          ],
        },
        {
          from: {
            key_code: 'f10',
          },
          to: [
            {
              key_code: 'mute',
            },
          ],
        },
        {
          from: {
            key_code: 'f11',
          },
          to: [
            {
              key_code: 'volume_decrement',
            },
          ],
        },
        {
          from: {
            key_code: 'f12',
          },
          to: [
            {
              key_code: 'volume_increment',
            },
          ],
        },
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
