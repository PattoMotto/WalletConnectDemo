import SwiftUI

struct ConnectView: View {
    @ObservedObject var viewModel: ConnectViewModel

    var body: some View {
        ZStack {
            Button("Connect") {
                viewModel.onTapConnect()
            }
            .buttonStyle(BorderedButtonStyle())
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
                Button("Disconnect", role: .destructive) {
                    viewModel.onTapDisconnect()
                }
                .buttonStyle(BorderedButtonStyle())
            }

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

#if DEBUG
#Preview {
    ConnectView(viewModel: ConnectViewModel(serivce: FakeWalletConnectService()))
}
#endif
