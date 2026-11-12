pub fn app_display_name() -> String {
    match option_env!("RUSTDESK_NAS_DISPLAY_NAME") {
        Some(name) if hbb_common::config::is_customer_build() => format!("{name}（顾客版）"),
        Some(name) => name.to_owned(),
        None => crate::get_app_name(),
    }
}

pub fn updates_disabled() -> bool {
    option_env!("RUSTDESK_NAS_DISPLAY_NAME").is_some()
        || hbb_common::config::is_customer_build()
}

#[cfg(test)]
mod nas_customization_tests {
    #[test]
    #[ignore = "requires the personalized build environment"]
    fn official_updates_and_server_settings_are_unavailable() {
        use base::config::keys;
        use hbb_common::config::{Config, LocalConfig};

        LocalConfig::set_option(
            keys::OPTION_ENABLE_CHECK_UPDATE.to_owned(),
            "Y".to_owned(),
        );
        Config::set_option(keys::OPTION_ALLOW_AUTO_UPDATE.to_owned(), "Y".to_owned());
        assert_eq!(
            LocalConfig::get_option(keys::OPTION_ENABLE_CHECK_UPDATE),
            "N"
        );
        assert_eq!(Config::get_option(keys::OPTION_ALLOW_AUTO_UPDATE), "N");
        assert_eq!(
            crate::common::get_builtin_option("nas-disable-software-update"),
            "Y"
        );
        assert_eq!(
            crate::common::get_builtin_option(keys::OPTION_HIDE_SERVER_SETTINGS),
            "Y"
        );
    }

    #[test]
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    #[ignore = "requires the personalized build environment"]
    fn official_update_requests_are_rejected() {
        let error = crate::updater::manually_check_update().unwrap_err();
        assert!(error.to_string().contains("updates are disabled"));
        crate::common::do_check_software_update().unwrap();
        assert!(crate::common::SOFTWARE_UPDATE_URL.lock().unwrap().is_empty());
    }

    #[test]
    #[ignore = "requires the personalized build environment"]
    fn branding_preserves_identity_and_disables_account_features() {
        let name = option_env!("RUSTDESK_NAS_DISPLAY_NAME").expect("personalized build");
        let customer = hbb_common::config::is_customer_build();
        assert_eq!(
            super::app_display_name(),
            if customer {
                format!("{name}（顾客版）")
            } else {
                name.to_owned()
            }
        );
        assert_eq!(
            crate::get_app_name(),
            if customer { "RustDeskCustomer" } else { "RustDesk" }
        );
        assert!(hbb_common::config::is_disable_account());
        assert!(hbb_common::config::is_disable_ab());
    }
}
