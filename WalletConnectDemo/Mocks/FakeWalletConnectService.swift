import Foundation
import WalletConnectSign

#if DEBUG
class FakeWalletConnectService: WalletConnectService {

    var authResponsePublisher: Published<Result<WalletConnectSign.Session, Error>?>.Publisher { $authResponse }

    @Published var authResponse: Result<WalletConnectSign.Session, Error>?

    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { $accountsDetails }

    @Published var accountsDetails = [AccountDetails]()

    var isConnectedPublisher: Published<Bool>.Publisher { $isConnected }

    @Published var isConnected = false

    func setup() {

    }

    func restoreSession() {

    }

    func connect() {

    }

    func disconnect() async -> Result<Bool, WalletConnectServiceError> {
        return .success(true)
    }

    func signInWithEtherium() async -> Result<Uri, WalletConnectServiceError> {
        return .failure(.cannotGenerateSignUri)
    }

    func handle(deeplink: String) {

    }
}
#endif
