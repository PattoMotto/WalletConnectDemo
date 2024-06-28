import WalletConnectSign

enum Proposal {
    static let requiredNamespaces: [String: ProposalNamespace] = [
        "eip155": ProposalNamespace(
            chains: [
                Blockchain("eip155:1")!
            ],
            methods: [
                "eth_sendTransaction",
                "personal_sign",
                "eth_signTypedData"
            ], events: []
        )
    ]
    
    static let optionalNamespaces: [String: ProposalNamespace] = [
        "eip155": ProposalNamespace(
            chains: [
                Blockchain("eip155:137")!
            ],
            methods: [
                "eth_sendTransaction",
                "personal_sign",
                "eth_signTypedData"
            ], events: []
        )
    ]
}
