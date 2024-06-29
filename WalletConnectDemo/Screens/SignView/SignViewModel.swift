import Foundation
import UIKit

class SignViewModel: ObservableObject {
    let uri: Uri
    @Published var qrCodeImageData: Data?

    init(uri: Uri) {
        defer { generateQR() }

        self.uri = uri
    }

    func copyToPasteboard() {
        UIPasteboard.general.string = uri.absoluteString
    }
}

// MARK: - Private
private extension SignViewModel {
    func generateQR() {
        Task { @MainActor in
            let qrCodeImage = QRCodeGenerator.generateQRCode(from: uri.absoluteString)
            qrCodeImageData = qrCodeImage.pngData()
        }
    }
}
