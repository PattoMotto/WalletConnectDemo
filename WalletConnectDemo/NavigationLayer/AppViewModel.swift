import Foundation

class AppViewModel: ObservableObject {
    @Published var screen: Screen

    private let walletConnectService: WalletConnectService

    init(
        screen: Screen = .splash,
        walletConnectService: WalletConnectService = WalletConnectServiceImpl()
    ) {
        self.screen = screen
        self.walletConnectService = walletConnectService
    }
    
    func didAppear() {
        if restoreSession() {
            screen = .wallet(WalletViewModel())
        } else {
            walletConnectService.bootstrap()
            screen = .connect(ConnectViewModel(serivce: walletConnectService))
        }
    }

    private func restoreSession() -> Bool {
        // TODO: Implement this!
        false
    }
}
