import SwiftUI

@main
struct WalletConnectDemoApp: App {
    private static let dependencies = DependenciesManager()

    private let appViewModel = AppViewModel(
        keychainService: dependencies.keychainService,
        walletConnectService: dependencies.walletConnectService,
        sessionManagerService: dependencies.sessionManagerService
    )

    var body: some Scene {
        WindowGroup {
            AppView(viewModel: appViewModel)
                .onOpenURL { url in
                    appViewModel.handleDeeplink(url)
                }
        }
    }
}
