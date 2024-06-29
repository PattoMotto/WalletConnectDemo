import SwiftUI

struct SignView: View {
    @ObservedObject var viewModel: SignViewModel

    var body: some View {
        VStack(alignment: .center, spacing: Constants.Spacing.default) {
            if
                let qrCodeImageData = viewModel.qrCodeImageData,
                let uiImage = UIImage(data: qrCodeImageData)
            {
                Image(uiImage: uiImage)
            }

            Button("Copy link") {
                viewModel.copyToPasteboard()
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding(.all, Constants.Padding.default)
    }
}
