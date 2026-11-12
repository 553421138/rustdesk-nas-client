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
