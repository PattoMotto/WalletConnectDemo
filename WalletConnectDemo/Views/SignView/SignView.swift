import SwiftUI

struct SignView: View {
    @ObservedObject var viewModel: SignViewModel

    var body: some View {
        VStack(alignment: .center, spacing: AppConstants.Spacing.default) {
            Text("Sign-In with Ethereum")
                .font(.largeTitle)

            Group {
                if
                    let qrCodeImageData = viewModel.qrCodeImageData,
                    let uiImage = UIImage(data: qrCodeImageData)
                {
                    Image(uiImage: uiImage)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small))
                } else {
                    LoadingView()
                }
            }
            .onAppear {
                viewModel.didAppear()
            }

            Button("Copy link") {
                viewModel.onTapCopyToPasteboard()
            }
            .buttonStyle(BorderedButtonStyle())
            .sensoryFeedback(.success, trigger: viewModel.copiedToPasteboardCounter)
        }
        .padding(.all, AppConstants.Padding.default)
    }
}
