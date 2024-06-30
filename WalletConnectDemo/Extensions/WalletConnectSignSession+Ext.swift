import WalletConnectSign

extension WalletConnectSign.Session {
    func toLocalSession() -> Session {
        Session(
            topic: topic,
            pairingTopic: pairingTopic,
            expiryDate: expiryDate
        )
    }
}
