use super::*;
use hbb_common::password_security::{self, ApproveMode};

#[tokio::test]
#[ignore = "requires RUSTDESK_NAS_EDITION=customer at build time"]
async fn customer_outgoing_connections_are_rejected() {
    assert!(config::is_customer_build());
    for peer in ["123456789", "127.0.0.1", "localhost:21118"] {
        for conn_type in [
            ConnType::DEFAULT_CONN,
            ConnType::FILE_TRANSFER,
            ConnType::PORT_FORWARD,
            ConnType::RDP,
            ConnType::VIEW_CAMERA,
            ConnType::TERMINAL,
        ] {
            let interface = Session::<crate::flutter::FlutterHandler>::default();
            interface.lc.write().unwrap().switch_uuid = Some(Uuid::new_v4().to_string());
            let result = timeout(200, Client::_start(peer, "", "", conn_type, interface))
            .await
            .expect("customer must be rejected before any connection or IPC request");
            assert_eq!(
                result.err().expect("outgoing connection was allowed").to_string(),
                "Incoming only mode (customer edition)"
            );
        }
    }
}

#[test]
#[ignore = "requires RUSTDESK_NAS_EDITION=customer at build time"]
fn customer_approval_cannot_be_changed_to_password() {
    assert!(config::is_customer_build());
    assert_eq!(crate::get_app_name(), "RustDeskCustomer");
    crate::trusted_devices::tests::initialize_config();
    Config::set_option("approve-mode".to_owned(), "password".to_owned());
    assert_eq!(password_security::approve_mode(), ApproveMode::Click);
    assert!(config::is_incoming_only());
}
