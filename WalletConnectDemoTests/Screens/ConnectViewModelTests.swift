import XCTest
@testable import WalletConnectDemo
import Combine

final class ConnectViewModelTests: XCTestCase {
    private var walletConnectService: MockWalletConnectService!
    private var sut: ConnectViewModel!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        walletConnectService = MockWalletConnectService()
        sut = ConnectViewModel(service: walletConnectService)
    }

    override func tearDownWithError() throws {
        sut = nil
        walletConnectService = nil
    }

    func testInitializeWithObservation() {
        XCTAssertFalse(sut.isConnected)
        XCTAssertNil(sut.error)

        let expectationIsConnected = expectation(description: "wait for isConnected to be changed")
        sut.$isConnected
            .filter { $0 }
            .sink { _ in
                expectationIsConnected.fulfill()
            }
            .store(in: &cancellables)

        let expectationError = expectation(description: "wait for error to be changed")
        sut.$error
            .filter {
                guard case .wallet(.unknown) = $0 else { return false }
                return true
            }
            .first()
            .sink { _ in
                expectationError.fulfill()
            }
            .store(in: &cancellables)

        walletConnectService.isConnected = true
        walletConnectService.error = .unknown

        wait(for: [expectationIsConnected, expectationError])
    }

    func testErrorDidDisappear() {
        sut.error = .wallet(.unknown)
        sut.errorDidDisappear()
        XCTAssertNil(sut.error)
    }

    func testOnTapConnect() {
        sut.onTapConnect()

        XCTAssertEqual(sut.buttonFeedbackCounter, 1)
        walletConnectService.invoked("connect()")
    }

    func testOnTapSignInWithEthereumWithSuccessResult() {
        walletConnectService.mockSignInWithEtheriumResult = .success(.mock)
        sut.onTapSignInWithEthereum()

        XCTAssertEqual(sut.buttonFeedbackCounter, 1)

        let expectationIsLoading = expectation(description: "wait for isLoading to be changed")
        sut.$isLoading
            .filter { $0 }
            .sink { _ in
                expectationIsLoading.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        walletConnectService.invoked("signInWithEtherium()")

        let expectationIsPresentedSignView = expectation(description: "wait for isPresentedSignView to be changed")
        sut.$isPresentedSignView
            .filter { $0 }
            .sink { _ in
                expectationIsPresentedSignView.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)

        XCTAssertTrue(sut.isPresentedSignView)
        XCTAssertNotNil(sut.signViewModel)
        XCTAssertNil(sut.error)
    }

    func testOnTapSignInWithEthereumWithFailureResult() {
        walletConnectService.mockSignInWithEtheriumResult = .failure(.unknown)
        sut.onTapSignInWithEthereum()

        XCTAssertEqual(sut.buttonFeedbackCounter, 1)

        let expectationIsLoading = expectation(description: "wait for isLoading to be changed")
        sut.$isLoading
            .filter { $0 }
            .sink { _ in
                expectationIsLoading.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
        walletConnectService.invoked("signInWithEtherium()")

        let expectationError = expectation(description: "wait for error to be changed")
        sut.$error
            .filter {
                guard case .wallet(.unknown) = $0 else { return false }
                return true
            }
            .first()
            .sink { _ in
                expectationError.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)

        XCTAssertFalse(sut.isPresentedSignView)
        XCTAssertNil(sut.signViewModel)
        XCTAssertNotNil(sut.error)
    }
}
