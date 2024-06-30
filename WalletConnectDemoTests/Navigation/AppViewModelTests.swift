import XCTest
@testable import WalletConnectDemo
import Combine

final class AppViewModelTests: XCTestCase {

    private var keychainService: MockKeychainService!
    private var walletConnectService: MockWalletConnectService!
    private var sessionManagerService: MockSessionManagerService!

    private var cancellables = Set<AnyCancellable>()

    private var sut: AppViewModel!

    override func setUpWithError() throws {
        keychainService = MockKeychainService()
        walletConnectService = MockWalletConnectService()
        sessionManagerService = MockSessionManagerService()
        sut = AppViewModel(
            keychainService: keychainService,
            walletConnectService: walletConnectService,
            sessionManagerService: sessionManagerService
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        sessionManagerService = nil
        keychainService = nil
        walletConnectService = nil
    }

    func testInitialize() {
        walletConnectService.invoked("setup()")
        sessionManagerService.invoked("restoreSession()")
    }

    func testInitialScreen() {
        XCTAssertEqual(sut.screen.name, "splash")
    }

    func testDidAppearWithoutValidSession() {
        sut.didAppear()

        let expectationScreen = expectation(description: "wait for screen to be changed")
        sut.$screen
            .filter { $0.name != "splash" }
            .sink { _ in
                expectationScreen.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 2)
        XCTAssertEqual(sut.screen.name, "connect")
    }

    func testDidAppearWithValidSession() {
        sut.didAppear()

        let expectationScreen = expectation(description: "wait for screen to be changed")
        sut.$screen
            .filter { $0.name != "splash" }
            .sink { _ in
                expectationScreen.fulfill()
            }
            .store(in: &cancellables)
        sessionManagerService.isValidSession = true
        waitForExpectations(timeout: 2)
        XCTAssertEqual(sut.screen.name, "wallet")
    }

    func testHandleDeeplink() {
        sut.handleDeeplink(URL(string: "http://hello.world")!)
        walletConnectService.invoked("handle(deeplink:)")
    }
}

extension Screen {
    var name: String {
        switch self {
        case .splash: "splash"
        case .connect: "connect"
        case .wallet: "wallet"
        }
    }
}
