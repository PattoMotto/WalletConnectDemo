import Foundation
import UIKit

class SignViewModel: ObservableObject {

    @MainActor
    @Published var qrCodeImageData: Data?
    @Published var copiedToPasteboardCounter = 0

    private let uri: Uri
    private let copyToPasteboardHandler: (String) -> Void
    private let qrCodeGenerator: (String) -> UIImage

    init(
        uri: Uri,
        copyToPasteboardHandler: @escaping (String) -> Void = Pasteboard.copy(text:),
        qrCodeGenerator: @escaping (String) -> UIImage = QRCodeGenerator.generateQRCode(from:)
    ) {
        self.uri = uri
        self.copyToPasteboardHandler = copyToPasteboardHandler
        self.qrCodeGenerator = qrCodeGenerator
    }

    func didAppear() {
        generateQR()
    }

    func onTapCopyToPasteboard() {
        copyToPasteboardHandler(uri.absoluteString)
        copiedToPasteboardCounter += 1
    }
}

// MARK: - Private
private extension SignViewModel {
    func generateQR() {
        let url = uri.absoluteString
        Task { @MainActor [weak self]  in
            guard let self, let pngData = self.qrCodeGenerator(url).pngData() else { return }
            self.qrCodeImageData = pngData
        }
    }
}
