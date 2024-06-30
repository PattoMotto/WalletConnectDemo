import Foundation
@testable import WalletConnectDemo

extension AccountDetails {
    static let mock = AccountDetails(chain: "eip155:1", methods: ["personal_sign"], account: "0x0")
}
