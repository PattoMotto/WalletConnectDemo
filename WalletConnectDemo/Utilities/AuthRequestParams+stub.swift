import WalletConnectSign

// MARK: - Authenticate request stub
extension AuthRequestParams {
    static func stub(
        domain: String = "pattomotto.com",
        chains: [String] = ["eip155:1"],
        nonce: String = "32891756",
        uri: String = "https://pattomotto.com",
        nbf: String? = nil,
        exp: String? = nil,
        statement: String? = "I accept the ServiceOrg Terms of Service: https://pattomotto.com/tos",
        requestId: String? = nil,
        resources: [String]? = nil,
        methods: [String]? = ["personal_sign", "eth_sendTransaction"]
    ) -> AuthRequestParams {
        return try! AuthRequestParams(
            domain: domain,
            chains: chains,
            nonce: nonce,
            uri: uri,
            nbf: nbf,
            exp: exp,
            statement: statement,
            requestId: requestId,
            resources: resources,
            methods: methods
        )
    }
}

