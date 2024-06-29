import Foundation

enum Constants {
    static let groupIdentifier = "group.com.pattomotto.wcdemo"

    enum CornerRadius {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32

        static var `default`: CGFloat { medium }
    }
    enum Padding {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32

        static var `default`: CGFloat { medium }
    }

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32

        static var `default`: CGFloat { medium }
    }
}
