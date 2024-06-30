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
    @Published var error: AppError?

    init(service: WalletConnectService) {
        self.service = service

        setup()
    }

    func errorDidDisappear() {
        self.error = nil
    }

    func onTapConnect() {
        triggerFeedback()
        service.connect()
    }

    func onTapSignInWithEthereum() {
        triggerFeedback()
        signInWithEtherium()
    }
}

// MARK: - Private
private extension ConnectViewModel {
    func setup() {
        self.isConnected = service.isConnected
        observeSession()
        observeError()
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

    func observeError() {
        service.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink {  error in
                if let error {
                    Task { @MainActor [weak self] in
                        self?.handle(error: error)
                    }
                }
            }
            .store(in: &cancellables)
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
                    self.handle(error: error)
                }
            }
        }
    }

    @MainActor
    func handle(error: WalletConnectServiceError) {
        self.error = .wallet(error)
    }
}
