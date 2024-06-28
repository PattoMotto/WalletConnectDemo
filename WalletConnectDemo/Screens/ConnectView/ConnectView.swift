import SwiftUI

struct ConnectView: View {
    @ObservedObject var viewModel: ConnectViewModel

    var body: some View {
        ZStack {
            Button("Connect") {
                viewModel.onTapConnect()
            }
            .disabled(viewModel.isLoading)

            if viewModel.isLoading {
                VStack {
                    ProgressView("Loading")
                        .padding(.top, 24)
                    Spacer()
                }
            }
            VStack {
                Spacer()
                Button("Disconnect") {
                    viewModel.onTapDisconnect()
                }
            }

        }
        .sheet(isPresented: $viewModel.isPresentedSignView) {
            if let signViewModel = viewModel.signViewModel {
                SignView(viewModel: signViewModel)
            }
        }
    }
}

#if DEBUG
#Preview {
    ConnectView(viewModel: ConnectViewModel(serivce: FakeWalletConnectService()))
}
#endif
