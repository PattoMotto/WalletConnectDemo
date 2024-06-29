import SwiftUI

struct SignView: View {
    @ObservedObject var viewModel: SignViewModel

    var body: some View {
        VStack(alignment: .center, spacing: Constants.Spacing.default) {
            Text("Sign-In with Ethereum")
                .font(.largeTitle)
            if
                let qrCodeImageData = viewModel.qrCodeImageData,
                let uiImage = UIImage(data: qrCodeImageData)
            {
                Image(uiImage: uiImage)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.small))
            }

            Button("Copy link") {
                viewModel.copyToPasteboard()
            }
            .buttonStyle(BorderedButtonStyle())
            .sensoryFeedback(.success, trigger: viewModel.copiedToPasteboardCounter)
        }
        .padding(.all, Constants.Padding.default)
    }
}
