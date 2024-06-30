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
            .sensoryFeedback(.success, trigger: viewModel.connectCounter)

            if viewModel.isLoading {
                VStack {
                    ProgressView("Loading")
                        .padding(.top, Constants.Padding.large)

                    Spacer()
                }
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
    ConnectView(viewModel: ConnectViewModel(service: FakeWalletConnectService()))
}
#endif
