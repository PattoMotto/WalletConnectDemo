import SwiftUI

@main
struct WalletConnectDemoApp: App {
    private let appViewModel = AppViewModel()
    var body: some Scene {
        WindowGroup {
            AppView(viewModel: appViewModel)
                .onOpenURL { url in
                    appViewModel.handleDeeplink(url)
                }
        }
    }
}
