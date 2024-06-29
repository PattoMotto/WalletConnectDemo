import Foundation
import UIKit

class SignViewModel: ObservableObject {
    let uri: Uri
    @Published var qrCodeImageData: Data?
    @Published var copiedToPasteboardCounter = 0

    init(uri: Uri) {
        defer { generateQR() }

        self.uri = uri
    }

    func copyToPasteboard() {
        Pasteboard.copy(text: uri.absoluteString)
        copiedToPasteboardCounter += 1
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
