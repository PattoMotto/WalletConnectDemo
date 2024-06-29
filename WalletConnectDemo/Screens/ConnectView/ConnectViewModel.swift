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
    @Published var connectCounter = 0

    init(service: WalletConnectService) {
        self.service = service
        observeSession()
    }
    
    func onTapConnect() {
        connectCounter += 1
        service.connect()
    }

    func observeSession() {
        service.accountsDetailsPublisher.receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isConnected = !value.isEmpty
                if !value.isEmpty {
                    self?.isLoading = true
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
            .store(in: &cancellables)
    }
}
