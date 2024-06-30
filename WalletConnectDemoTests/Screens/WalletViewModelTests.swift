import XCTest
@testable import WalletConnectDemo
import Combine

final class WalletViewModelTests: XCTestCase {
    private var walletConnectService: MockWalletConnectService!
    private var sessionManagerService: MockSessionManagerService!
    private var copyToPasteboardCalledWithText: String?

    private var sut: WalletViewModel!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        walletConnectService = MockWalletConnectService()
        sessionManagerService = MockSessionManagerService()
        sut = WalletViewModel(
            walletConnectService: walletConnectService,
            sessionManagerService: sessionManagerService,
            copyToPasteboardHandler: { [weak self] in
                self?.copyToPasteboardCalledWithText = $0
            }
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        sessionManagerService = nil
        walletConnectService = nil
        copyToPasteboardCalledWithText = nil
    }

    func testInitializeWithObservation() {
        XCTAssertNil(sut.error)
        XCTAssertNil(sut.addressId)

        let expectationAddressId = expectation(description: "wait for addressId to be changed")
        sut.$addressId
            .filter { $0 != nil }
            .sink { _ in
                expectationAddressId.fulfill()
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

        walletConnectService.error = .unknown
        walletConnectService.accountsDetails = [.mock]

        wait(for: [expectationAddressId, expectationError])
    }

    func testErrorDidDisappear() {
        sut.error = .wallet(.unknown)
        sut.errorDidDisappear()
        XCTAssertNil(sut.error)
    }

    func testOnTapDisconnectWithSuccess() {
        walletConnectService.mockDisconnectResult = .success(true)

        sut.onTapDisconnect()

        XCTAssertTrue(sut.isDisconnecting)
        let expectationIsDisconnecting = expectation(description: "wait for isDisconnecting to be changed")
        sut.$isDisconnecting
            .filter { $0 == false }
            .sink { _ in
                expectationIsDisconnecting.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)

        walletConnectService.invoked("disconnect()")
        sessionManagerService.invoked("clearSession()")
    }

    func testOnTapDisconnectWithFailureResult() {
        walletConnectService.mockDisconnectResult = .failure(.unknown)

        sut.onTapDisconnect()

        XCTAssertTrue(sut.isDisconnecting)
        let expectationIsDisconnecting = expectation(description: "wait for isDisconnecting to be changed")
        sut.$isDisconnecting
            .filter { $0 == false }
            .sink { _ in
                expectationIsDisconnecting.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)

        walletConnectService.invoked("disconnect()")
        sessionManagerService.notInvoked("clearSession()")
        XCTAssertNotNil(sut.error)
    }

    func testOnTapCopyAddressToPasteboard() {
        sut.addressId = "0x0"
        sut.onTapCopyAddressToPasteboard()
        XCTAssertEqual(copyToPasteboardCalledWithText, "0x0")
        XCTAssertEqual(sut.copiedToPasteboardCounter, 1)
    }
}
