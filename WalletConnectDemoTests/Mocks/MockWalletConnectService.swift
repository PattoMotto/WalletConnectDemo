@testable import WalletConnectDemo
import Combine

final class MockWalletConnectService: Spy, WalletConnectService {
    var mockDisconnectResult: Result<Bool, WalletConnectServiceError>?
    var mockSignInWithEtheriumResult: Result<Uri, WalletConnectServiceError>?

    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { $accountsDetails }

    var authResponsePublisher: Published<Result<Session, WalletConnectServiceError>?>.Publisher { $authResponse }

    var errorPublisher: Published<WalletConnectServiceError?>.Publisher { $error }

    var isConnectedPublisher: Published<Bool>.Publisher { $isConnected }

    @Published var accountsDetails = [AccountDetails]()
    @Published var authResponse: Result<Session, WalletConnectServiceError>?
    @Published var error: WalletConnectServiceError?
    @Published var isConnected = false

    func setup() {
        record()
    }

    func connect() {
        record()
    }

    func disconnect() async -> Result<Bool, WalletConnectServiceError> {
        record()
        return mockDisconnectResult ?? .failure(.unknown)
    }

    func signInWithEtherium() async -> Result<Uri, WalletConnectServiceError> {
        record()
        return mockSignInWithEtheriumResult ?? .failure(.unknown)
    }

    func handle(deeplink: String) {
        record()
    }
}
