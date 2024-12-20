_: {
  services.kanata = {
    enable = true;

    keyboards.kbd = {
      port = 4743;
      devices = [
        "/dev/input/by-id/usb-Gtech_Magnetic_Wired_Keyboard-event-kbd"
        "/dev/input/by-id/usb-Logitech_USB_Receiver-event-mouse"
        "/dev/input/by-id/usb-Razer_Razer_DeathAdder_V3_Pro_000000000000-event-mouse"
      ];
      config = ''
        (defsrc
          mfwd mbck
          esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc del
          tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    pgup
          home a    s    d    f    g    h    j    k    l    ;    '    ret       pgdn
          lsft z    x    c    v    b    n    m    ,    .    /    rsft           up
          lctl lmet lalt           spc            ralt rmet rctl           lft  down rght
        )

        (deflayer qwerty
          mfwd mbck
          esc  1    2    3    4    5    6    7    8    9    0    -    =   bspc  del
          tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    pgup
          home a    s    d    f    g    h    j    k    l    ;    '    ret       @swch
          lsft z    x    c    v    b    n    m    ,    .    /    rsft           up
          lctl lmet lalt           spc            ralt rmet rctl           lft  down rght
        )

        (deflayer gw2
          lctl   _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _         @swch
            _    _    _    _    _    _    _    _    _    _    _    _              _
            _    _    _              _              _    _    _               _   _   _
        )

        (defalias
          swch (tap-hold 200 200 esc (layer-toggle layers))
          ;; layer-switch changes the base layer.
          gw2 (layer-switch gw2)
          qwerty (layer-switch qwerty)
        )

        (deflayer layers
            _ _
            _ @qwerty @gw2 _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _         @swch
            _    _    _    _    _    _    _    _    _    _    _    _              _
            _    _    _              _              _    _    _               _   _   _
        )
      '';
    };
  };
}
