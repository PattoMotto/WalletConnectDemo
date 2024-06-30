import SwiftUI

struct SignView: View {
    @ObservedObject var viewModel: SignViewModel
    @State private var qrCodeImage: UIImage?

    var body: some View {
        VStack(alignment: .center, spacing: AppConstants.Spacing.default) {
            Text("Sign-In with Ethereum")
                .font(.largeTitle)

            Group {
                if let uiImage = qrCodeImage {
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
        .onChange(of: viewModel.qrCodeImageData) { oldValue, newValue in
            guard let data = newValue else { return }
            qrCodeImage = UIImage(data: data)
        }
    }
}
