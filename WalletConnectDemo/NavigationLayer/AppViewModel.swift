import Foundation
import Combine
class AppViewModel: ObservableObject {
    @Published var screen: Screen

    private var cancellables = Set<AnyCancellable>()

    private let walletConnectService: WalletConnectService

    init(
        screen: Screen = .splash,
        walletConnectService: WalletConnectService = WalletConnectServiceImpl()
    ) {
        defer { setup() }

        self.screen = screen
        self.walletConnectService = walletConnectService
    }

    private func setup() {
        walletConnectService.setup()
        observeSIWE()
    }

    func didAppear() {
        // Delay 1 second to show the splash screen and preload data
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            guard let self else { return }
            self.autoUpdateScreen(isValidSession: self.walletConnectService.isValidSession)
        }
    }

    func handleDeeplink(_ url: URL) {
        walletConnectService.handle(deeplink: url.absoluteString)
        // TODO: Implement this!
    }

    private func observeSIWE() {
        walletConnectService.isValidSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isSIWE in
                self.autoUpdateScreen(isValidSession: isSIWE)
            }.store(in: &cancellables)
    }

    private func autoUpdateScreen(isValidSession: Bool) {
        if isValidSession {
            screen = .wallet(WalletViewModel(service: walletConnectService))
        } else {
            screen = .connect(ConnectViewModel(service: walletConnectService))
        }
    }
}
