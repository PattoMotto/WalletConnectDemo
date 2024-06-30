import Foundation
import Combine

class WalletViewModel: ObservableObject {
    @Published var addressId: String?
    @Published var copiedToPasteboardCounter = 0
    @Published var isDisconnecting = false

    private var cancellables = Set<AnyCancellable>()
    private let walletConnectService: WalletConnectService
    private let sessionManagerService: SessionManagerService

    init(
        walletConnectService: WalletConnectService,
        sessionManagerService: SessionManagerService
    ) {
        self.walletConnectService = walletConnectService
        self.sessionManagerService = sessionManagerService

        observeAddressId()
    }

    func onTapDisconnect() {
        isDisconnecting = true
        Task {
            let result = await walletConnectService.disconnect()
            switch result {
            case .success:
                print("Disconnected")
            case .failure(let error):
                print(error)
            }
            sessionManagerService.clearSession()
        }
    }

    func copyAddressToPasteboard() {
        if let addressId {
            Pasteboard.copy(text: addressId)
            copiedToPasteboardCounter += 1
        }
    }
}

// MARK: - Private
private extension WalletViewModel {
    func observeAddressId() {
        walletConnectService.accountsDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accountsDetails in
                self?.addressId = accountsDetails.first?.account
            }
            .store(in: &cancellables)
    }
}
