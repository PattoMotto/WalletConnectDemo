import UIKit

enum Pasteboard {
    static func copy(text: String) {
        UIPasteboard.general.string = text
    }
}
