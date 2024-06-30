import XCTest
@testable import WalletConnectDemo
import Combine

final class SessionManagerServiceTests: XCTestCase {
    private var keychainService: MockKeychainService!
    private var walletConnectService: MockWalletConnectService!

    private var cancellables = Set<AnyCancellable>()

    private var sut: SessionManagerServiceImpl!

    override func setUpWithError() throws {
        keychainService = MockKeychainService()
        walletConnectService = MockWalletConnectService()
        sut = SessionManagerServiceImpl(
            keychainService: keychainService,
            walletConnectService: walletConnectService
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        keychainService = nil
        walletConnectService = nil
    }

    func testInitializeWithAuthResponseObservation() {
        XCTAssertFalse(sut.isValidSession)

        walletConnectService.authResponse = .success(.mock)

        let expectation = expectation(description: "wait for isValidSession to be changed")
        sut.isValidSessionPublisher
            .filter { $0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)
    }

    func testRestoreSession() {
        XCTAssertFalse(sut.isValidSession)
        keychainService.mockReadData = Session.mock

        sut.restoreSession()

        keychainService.invoked("read(key:)")
        XCTAssertTrue(sut.isValidSession)
    }

    func testClearSession() {
        sut.clearSession()
        keychainService.invoked("delete(key:)")
    }
}

extension Session {
    static let mock = Session(
        topic: "topic",
        pairingTopic: "pairingTopic",
        expiryDate: Date().addingTimeInterval(60)
    )
}
