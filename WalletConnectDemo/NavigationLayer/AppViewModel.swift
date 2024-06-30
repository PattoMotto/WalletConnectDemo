import Foundation
import Combine
class AppViewModel: ObservableObject {
    @Published var screen: Screen

    private var cancellables = Set<AnyCancellable>()

    private let keychainService: KeychainService
    private let walletConnectService: WalletConnectService
    private let sessionManagerService: SessionManagerService

    init(
        screen: Screen = .splash,
        keychainService: KeychainService,
        walletConnectService: WalletConnectService,
        sessionManagerService: SessionManagerService
    ) {
        self.screen = screen
        self.keychainService = keychainService
        self.walletConnectService = walletConnectService
        self.sessionManagerService = sessionManagerService

        setup()
    }

    private func setup() {
        walletConnectService.setup()
        sessionManagerService.restoreSession()
    }

    func didAppear() {
        // Delay 1 second to show the splash screen and preload data
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            guard let self else { return }
            observeValidSession()
        }
    }

    func handleDeeplink(_ url: URL) {
        walletConnectService.handle(deeplink: url.absoluteString)
        // TODO: Implement this!
    }

    private func observeValidSession() {
        sessionManagerService.isValidSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isValidSession in
                self.autoUpdateScreen(isValidSession: isValidSession)
            }.store(in: &cancellables)
    }

    private func autoUpdateScreen(isValidSession: Bool) {
        if isValidSession {
            screen = .wallet(
                WalletViewModel(
                    walletConnectService: walletConnectService,
                    sessionManagerService: sessionManagerService
                )
            )
        } else {
            screen = .connect(ConnectViewModel(service: walletConnectService))
        }
    }
}
