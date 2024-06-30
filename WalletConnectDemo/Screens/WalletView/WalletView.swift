import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel: WalletViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.default) {
            HStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()

                Spacer()
                
                Button("Disconnect", role: .destructive) {
                    viewModel.onTapDisconnect()
                }
                .buttonStyle(BorderedButtonStyle())
                .sensoryFeedback(.warning, trigger: viewModel.isDisconnecting)
            }


            if let addressId = viewModel.addressId {
                VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                    Text("Your address")
                        .font(.title)

                    Text(addressId)
                        .font(.subheadline)
                    
                    Button("Copy address") {
                        viewModel.copyAddressToPasteboard()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .sensoryFeedback(.success, trigger: viewModel.copiedToPasteboardCounter)
                }
            } else {
                VStack(alignment: .center) {
                    ProgressView("Loading")
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(.all, Constants.Padding.default)
    }
}
