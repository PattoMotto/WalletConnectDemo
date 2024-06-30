import SwiftUI

struct AppView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Group {
            switch viewModel.screen {
            case .splash:
                SplashView()
            case .wallet(let walletViewModel):
                WalletView(viewModel: walletViewModel)
            case .connect(let connectViewModel):
                ConnectView(viewModel: connectViewModel)
            }
        }
        .onAppear {
            viewModel.didAppear()
        }
    }
}
