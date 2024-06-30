import Foundation
import Combine

class WalletViewModel: ObservableObject {
    @Published var addressId: String?
    @Published var copiedToPasteboardCounter = 0
    @Published var disconnectCounter = 0
    @Published var isDisconnecting = false
    @Published var error: AppError?

    private var cancellables = Set<AnyCancellable>()
    private let walletConnectService: WalletConnectService
    private let sessionManagerService: SessionManagerService
    private let copyToPasteboardHandler: (String) -> Void

    init(
        walletConnectService: WalletConnectService,
        sessionManagerService: SessionManagerService,
        copyToPasteboardHandler: @escaping (String) -> Void = Pasteboard.copy(text:)
    ) {
        self.walletConnectService = walletConnectService
        self.sessionManagerService = sessionManagerService
        self.copyToPasteboardHandler = copyToPasteboardHandler

        setup()
    }

    func errorDidDisappear() {
        self.error = nil
    }

    func onTapDisconnect() {
        disconnectCounter += 1
        isDisconnecting = true
        Task {
            let result = await walletConnectService.disconnect()
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success:
                    self.sessionManagerService.clearSession()
                case .failure(let error):
                    self.handle(error: error)
                }
                self.isDisconnecting = false
            }
        }
    }

    func onTapCopyAddressToPasteboard() {
        if let addressId {
            copyToPasteboardHandler(addressId)
            copiedToPasteboardCounter += 1
        }
    }
}

// MARK: - Private
private extension WalletViewModel {
    func setup() {
        observeAddressId()
        observeError()
    }

    func observeAddressId() {
        walletConnectService.accountsDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] accountsDetails in
                guard let self,
                      let addressId = accountsDetails.first?.account else {
                    return
                }
                self.update(addressId: addressId)
            }
            .store(in: &cancellables)
    }

    func observeError() {
        walletConnectService.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error else { return }
                self?.handle(error: error)
            }
            .store(in: &cancellables)
    }

    func update(addressId: String) {
        guard self.addressId != addressId else { return }
        self.addressId = addressId
    }

    func handle(error: WalletConnectServiceError) {
        self.error = .wallet(error)
    }
}
