import SwiftUI

struct SignView: View {
    @ObservedObject var viewModel: SignViewModel

    var body: some View {
        VStack(alignment: .center, spacing: AppConstants.Spacing.default) {
            Text("Sign-In with Ethereum")
                .font(.largeTitle)
            if
                let qrCodeImageData = viewModel.qrCodeImageData,
                let uiImage = UIImage(data: qrCodeImageData)
            {
                Image(uiImage: uiImage)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small))
            } else {
                LoadingView()
            }

            Button("Copy link") {
                viewModel.copyToPasteboard()
            }
            .buttonStyle(BorderedButtonStyle())
            .sensoryFeedback(.success, trigger: viewModel.copiedToPasteboardCounter)
        }
        .padding(.all, AppConstants.Padding.default)
    }
}
