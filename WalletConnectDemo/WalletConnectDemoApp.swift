import SwiftUI

@main
struct WalletConnectDemoApp: App {
    private let appRouter = AppRouter()
    var body: some Scene {
        WindowGroup {
            appRouter.view()
                .onOpenURL { url in
                    appRouter.handleDeeplink(url)
                }
        }
    }
}
