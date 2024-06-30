import Foundation
import Combine

class WalletViewModel: ObservableObject {
    @Published var addressId: String?
    @Published var copiedToPasteboardCounter = 0
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
        isDisconnecting = true
        Task {
            let result = await walletConnectService.disconnect()
            switch result {
            case .success:
                sessionManagerService.clearSession()
            case .failure(let error):
                await handle(error: error)
            }
            isDisconnecting = false
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
                self?.addressId = accountsDetails.first?.account
            }
            .store(in: &cancellables)
    }

    func observeError() {
        walletConnectService.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { error in
                guard let error else { return }
                Task { @MainActor [weak self] in
                    self?.handle(error: error)
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func handle(error: WalletConnectServiceError) {
        self.error = .wallet(error)
    }
}
