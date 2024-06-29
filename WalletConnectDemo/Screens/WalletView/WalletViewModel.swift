import Foundation

class WalletViewModel: ObservableObject {
    @Published var addressId: String?
    @Published var copiedToPasteboardCounter = 0
    @Published var isDisconnecting = false

    private let service: WalletConnectService

    init(service: WalletConnectService) {
        self.service = service
        self.addressId = service.accountsDetails.first?.account
    }

    func onTapDisconnect() {
        isDisconnecting = true
        Task {
            let result = await service.disconnect()
            switch result {
            case .success:
                print("Disconnected")
            case .failure(let error):
                print(error)
            }
        }
    }

    func copyAddressToPasteboard() {
        if let addressId {
            Pasteboard.copy(text: addressId)
            copiedToPasteboardCounter += 1
        }
    }
}
