import Foundation
import WalletConnectSign

#if DEBUG
class FakeWalletConnectService: WalletConnectService {
    var authResponsePublisher: Published<Result<WalletConnectSign.Session, Error>?>.Publisher { $authResponse }

    @Published var authResponse: Result<WalletConnectSign.Session, Error>?

    var isValidSessionPublisher: Published<Bool>.Publisher { $isValidSession }

    @Published var isValidSession = false

    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { $accountsDetails }

    @Published var accountsDetails = [AccountDetails]()

    var isConnected = false

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
