import Foundation
import UIKit

class SignViewModel: ObservableObject {
    let uri: Uri

    init(uri: Uri) {
        self.uri = uri
    }

    func copyToPasteboard() {
        UIPasteboard.general.string = uri.absoluteString
    }
}
