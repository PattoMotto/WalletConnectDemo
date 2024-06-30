import Foundation
import Combine
import WalletConnectSign

protocol SessionManagerService {
    var isValidSessionPublisher: Published<Bool>.Publisher { get }
    func restoreSession()
    func clearSession()
}

class SessionManagerServiceImpl: SessionManagerService {
    enum Constants {
        static let sessionKey = "session"
    }

    var isValidSessionPublisher: Published<Bool>.Publisher { $isValidSession }
    @Published var isValidSession = false

    private var cancellables = Set<AnyCancellable>()

    private let keychainService: KeychainService
    private let walletConnectService: WalletConnectService

    private var session: Session? {
        didSet {
            isValidSession = session != nil
        }
    }

    init(keychainService: KeychainService, walletConnectService: WalletConnectService) {
        self.keychainService = keychainService
        self.walletConnectService = walletConnectService

        observeAuthResponse()
    }

    private func observeAuthResponse() {
        walletConnectService.authResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let session):
                    self.session = session
                    self.store(session: session)
                case .failure(let error):
                    self.session = nil
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func restoreSession() {
        if let storedSession: WalletConnectSign.Session = try? self.keychainService.read(key: Constants.sessionKey) {
            session = storedSession.isValid == true ? storedSession : nil
        }
    }

    func clearSession() {
        do {
            try keychainService.delete(key: Constants.sessionKey)
            session = nil
        } catch {
            print(error)
        }
    }
}

private extension SessionManagerServiceImpl {
    func store(session: Session) {
        let key = Constants.sessionKey
        Task {
            do {
                if let storedSession: WalletConnectSign.Session = try keychainService.read(key: key),
                   storedSession.expiryDate != session.expiryDate {
                    try keychainService.update(key: key, value: session)
                } else {
                    try keychainService.create(key: key, value: session)
                }
            } catch {
                print(error)
            }
        }
    }
}

private extension Session {
    var isValid: Bool {
        expiryDate > Date()
    }
}
