import SwiftUI

struct ConnectView: View {
    @ObservedObject var viewModel: ConnectViewModel

    var body: some View {
        ZStack {
            if viewModel.isConnected {
                signInWithEthereumButton
            } else {
                connectButton
            }

            if viewModel.isLoading {
                VStack {
                    LoadingView()
                        .padding(.top, Constants.Padding.large)

                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.didAppear()
        }
        .sheet(isPresented: $viewModel.isPresentedSignView) {
            if let signViewModel = viewModel.signViewModel {
                SignView(viewModel: signViewModel)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    viewModel.sheetHeight = geo.size.height
                                }
                                .onChange(of: geo.size) { oldValue, newValue in
                                    viewModel.sheetHeight = newValue.height
                                }
                        }
                    )
                    .presentationDetents([.height(viewModel.sheetHeight)])
            }
        }
    }
}

// MARK: - Private
private extension ConnectView {
    @ViewBuilder var signInWithEthereumButton: some View {
        Button("Sign-In with Ethereum") {
            viewModel.onTapSignInWithEthereum()
        }
        .buttonStyle(BorderedButtonStyle())
        .disabled(viewModel.isLoading)
        .sensoryFeedback(.success, trigger: viewModel.buttonFeedbackCounter)
    }

    @ViewBuilder var connectButton: some View {
        Button("Connect") {
            viewModel.onTapConnect()
        }
        .buttonStyle(BorderedButtonStyle())
        .disabled(viewModel.isLoading)
        .sensoryFeedback(.success, trigger: viewModel.buttonFeedbackCounter)
    }
}

#if DEBUG
#Preview {
    ConnectView(viewModel: ConnectViewModel(service: FakeWalletConnectService()))
}
#endif
