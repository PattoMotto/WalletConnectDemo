import Foundation
import SwiftUI
import UIKit
import WalletConnectNetworking
import WalletConnectSign
import Combine

enum Constants {
    static let groupIdentifier = "group.com.pattomotto.wcdemo"
}

class ConnectViewModel: ObservableObject {
    private let serivce: WalletConnectService
    private var cancellables = Set<AnyCancellable>()

    @Published var signViewModel: SignViewModel?
    @Published var isPresentedSignView = false
    @Published var isLoading = false
    @Published var isConnected = false

    init(serivce: WalletConnectService) {
        self.serivce = serivce
        observeSession()
    }
    
    func onTapConnect() {
        serivce.connect()
    }

    func onTapDisconnect() {
        Task {
            let result = await serivce.disconnect()
            switch result {
            case .success:
                print("Disconnected")
            case .failure(let error):
                print(error)
            }
        }
    }

    func observeSession() {
        serivce.accountsDetailsPublisher.receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.isConnected = !value.isEmpty
                if !value.isEmpty {
                    self?.isLoading = true
                    Task { [weak self] in
                        guard let self else { return }
                        let result = await self.serivce.signInWithEtherium()
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
