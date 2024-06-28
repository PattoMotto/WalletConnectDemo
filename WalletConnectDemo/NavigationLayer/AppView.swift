import SwiftUI

struct AppView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        switch viewModel.screen {
        case .splash:
            SplashView()
        case .wallet(let walletViewModel):
            WalletView(viewModel: walletViewModel)
        case .connect(let connectViewModel):
            ConnectView(viewModel: connectViewModel)
        }
    }
}

#Preview {
    AppView(viewModel: AppViewModel(screen: .splash))
}
