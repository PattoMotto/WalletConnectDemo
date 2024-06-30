import Foundation
import SwiftUI
import UIKit
import WalletConnectNetworking
import WalletConnectSign
import Combine

class ConnectViewModel: ObservableObject {
    private let service: WalletConnectService
    private var cancellables = Set<AnyCancellable>()

    @Published var signViewModel: SignViewModel?
    @Published var isPresentedSignView = false
    @Published var isLoading = false
    @Published var isConnected = false
    @Published var sheetHeight: CGFloat = 0
    @Published var buttonFeedbackCounter = 0

    init(service: WalletConnectService) {
        self.service = service

        setup()
    }

    func didAppear() {
        service.restoreSession()
    }

    func onTapConnect() {
        triggerFeedback()
        service.connect()
    }

    func onTapSignInWithEthereum() {
        triggerFeedback()
        signInWithEtherium()
    }

    func observeSession() {
        service.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self else { return }

                self.isConnected = isConnected
                if isConnected {
                    self.signInWithEtherium()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private
private extension ConnectViewModel {
    func setup() {
        self.isConnected = service.isConnected
        observeSession()
    }

    func triggerFeedback() {
        buttonFeedbackCounter += 1
    }

    func signInWithEtherium() {
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            let result = await self.service.signInWithEtherium()
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let uri):
                    self.signViewModel = SignViewModel(uri: uri)
                    self.isPresentedSignView = true
                case .failure(let error):
                    print("PM: ", error)
                }
            }
        }
    }
}
