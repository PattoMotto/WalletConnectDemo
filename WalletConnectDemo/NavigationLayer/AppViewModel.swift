import Foundation

class AppViewModel: ObservableObject {
    @Published var screen: Screen

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
        observeAccountDetails()
    }

    func didAppear() {
        if walletConnectService.isConnected {
            screen = .wallet(WalletViewModel())
        } else {
            screen = .connect(ConnectViewModel(serivce: walletConnectService))
        }
    }

    func handleDeeplink(_ url: URL) {
        walletConnectService.handle(deeplink: url.absoluteString)
    }

    private func observeAccountDetails() {
        // TODO: Implement this!
    }
}
