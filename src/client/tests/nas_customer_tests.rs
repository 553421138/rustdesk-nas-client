use super::*;
use hbb_common::password_security::{self, ApproveMode};

#[tokio::test]
async fn customer_outgoing_connections_are_rejected() {
    if !config::is_customer_build() {
        return;
    }
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
fn customer_approval_cannot_be_changed_to_password() {
    if !config::is_customer_build() {
        return;
    }
    crate::trusted_devices::tests::initialize_config();
    Config::set_option("approve-mode".to_owned(), "password".to_owned());
    assert_eq!(password_security::approve_mode(), ApproveMode::Click);
    assert!(config::is_incoming_only());
}
