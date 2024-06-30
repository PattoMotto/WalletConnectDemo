import XCTest
@testable import WalletConnectDemo
import Combine

final class SignViewModelTests: XCTestCase {
    private var copyToPasteboardCalledWithText: String?
    private var qrCodeGeneratorCalledWithText: String?

    private var sut: SignViewModel!

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        sut = SignViewModel(
            uri: .mock,
            copyToPasteboardHandler: { [weak self] in
                self?.copyToPasteboardCalledWithText = $0
            },
            qrCodeGenerator: { [weak self] text in
                self?.qrCodeGeneratorCalledWithText = text
                return UIImage()
            }
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        copyToPasteboardCalledWithText = nil
        qrCodeGeneratorCalledWithText = nil
    }

    func testDidAppear() {
        sut.didAppear()

        let expectationQrCodeImageData = expectation(description: "wait for qrCodeImageData to be changed")
        sut.$qrCodeImageData
            .filter { $0 == nil }
            .first()
            .sink { _ in
                expectationQrCodeImageData.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)
        XCTAssertEqual(qrCodeGeneratorCalledWithText, "wc://abc")
    }

    func testOnTapCopyToPasteboard() {
        sut.onTapCopyToPasteboard()
        XCTAssertEqual(copyToPasteboardCalledWithText, "wc://abc")
        XCTAssertEqual(sut.copiedToPasteboardCounter, 1)
    }
}
