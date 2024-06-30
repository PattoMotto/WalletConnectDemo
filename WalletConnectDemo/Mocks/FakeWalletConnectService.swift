import Foundation
import WalletConnectSign

#if DEBUG
class FakeWalletConnectService: WalletConnectService {
    var authResponsePublisher: Published<Result<Session, WalletConnectServiceError>?>.Publisher { $authResponse }

    @Published var authResponse: Result<Session, WalletConnectServiceError>?

    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { $accountsDetails }

    @Published var accountsDetails = [AccountDetails]()

    var isConnectedPublisher: Published<Bool>.Publisher { $isConnected }

    @Published var isConnected = false

    var errorPublisher: Published<WalletConnectServiceError?>.Publisher { $error }

    @Published var error: WalletConnectServiceError?

    func setup() {

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
