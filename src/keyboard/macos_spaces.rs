use rdev::{EventType, Key};

#[cfg(target_os = "macos")]
pub(super) fn keep_local(event: &rdev::Event) -> bool {
    if option_env!("RUSTDESK_NAS_DISPLAY_NAME").is_none() {
        return false;
    }
    let key = match event.event_type {
        EventType::KeyPress(key) | EventType::KeyRelease(key)
            if matches!(key, Key::LeftArrow | Key::RightArrow) => key,
        _ => return false,
    };
    let bare_control = {
        let modifiers = super::MODIFIERS_STATE.lock().unwrap();
        let held = |key| modifiers.get(&key).copied().unwrap_or(false);
        (held(Key::ControlLeft) || held(Key::ControlRight))
            && ![
                Key::ShiftLeft, Key::ShiftRight, Key::Alt,
                Key::AltGr, Key::MetaLeft, Key::MetaRight,
            ]
            .iter()
            .any(|key| held(*key))
    };
    let remote_pressed = super::TO_RELEASE.lock().unwrap().contains_key(&key);
    route_locally(&event.event_type, bare_control, remote_pressed)
}

fn route_locally(event: &EventType, bare_control: bool, remote_pressed: bool) -> bool {
    match event {
        EventType::KeyPress(Key::LeftArrow | Key::RightArrow) => bare_control,
        // Pair an arrow already sent to the peer, even when Control changed meanwhile.
        EventType::KeyRelease(Key::LeftArrow | Key::RightArrow) => !remote_pressed,
        _ => false,
    }
}

#[cfg(test)]
mod nas_customization_tests {
    use super::*;

    #[test]
    fn control_arrows_stay_local_without_changing_other_remote_keys() {
        for key in [Key::LeftArrow, Key::RightArrow] {
            assert!(route_locally(&EventType::KeyPress(key), true, false));
            assert!(route_locally(&EventType::KeyRelease(key), false, false));
            assert!(!route_locally(&EventType::KeyPress(key), false, false));
        }
        assert!(!route_locally(&EventType::KeyPress(Key::KeyC), true, false));
        assert!(!route_locally(&EventType::KeyPress(Key::UpArrow), true, false));
    }

    #[test]
    fn remote_arrow_release_is_preserved_when_control_is_pressed_later() {
        for key in [Key::LeftArrow, Key::RightArrow] {
            assert!(!route_locally(&EventType::KeyRelease(key), true, true));
            assert!(!route_locally(&EventType::KeyRelease(key), false, true));
        }
    }
}
