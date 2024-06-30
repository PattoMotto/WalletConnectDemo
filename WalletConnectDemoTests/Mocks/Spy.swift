import XCTest

class Spy {
    private var invokedFunctionName = [String]()

    func invoked(_ functionName: String) {
        XCTAssertTrue(invokedFunctionName.contains(functionName))
    }

    func notInvoked(_ functionName: String) {
        XCTAssertFalse(invokedFunctionName.contains(functionName))
    }

    func record(_ functionName: String = #function) {
        invokedFunctionName.append(functionName)
    }
}
