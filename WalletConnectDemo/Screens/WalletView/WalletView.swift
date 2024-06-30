import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel: WalletViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.default) {
            HStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()

                Spacer()
                
                Button("Disconnect", role: .destructive) {
                    viewModel.onTapDisconnect()
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(viewModel.isDisconnecting)
                .sensoryFeedback(.warning, trigger: viewModel.isDisconnecting)
            }


            if let addressId = viewModel.addressId {
                VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                    Text("Your address")
                        .font(.title)

                    Text(addressId)
                        .font(.subheadline)
                    
                    Button("Copy address") {
                        viewModel.onTapCopyAddressToPasteboard()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .sensoryFeedback(.success, trigger: viewModel.copiedToPasteboardCounter)
                }
            } else {
                VStack(alignment: .center) {
                    LoadingView()
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(.all, AppConstants.Padding.default)
        .showError(error: viewModel.error) {
            viewModel.errorDidDisappear()
        }
    }
}
