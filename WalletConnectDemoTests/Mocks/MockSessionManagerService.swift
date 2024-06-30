@testable import WalletConnectDemo
import Combine

final class MockSessionManagerService: Spy, SessionManagerService {
    var isValidSessionPublisher: Published<Bool>.Publisher { $isValidSession }
    @Published var isValidSession = false

    func restoreSession() {
        record()
    }

    func clearSession() {
        record()
    }
}
