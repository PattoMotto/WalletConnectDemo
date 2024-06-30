import SwiftUI

struct ErrorView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.title3)
            .foregroundStyle(.red)
            .padding(.all, AppConstants.Padding.default)
            .background(.red.opacity(0.1))
            .clipShape(.capsule)
            .padding(.top, AppConstants.Padding.large)
    }
}

#Preview {
    ErrorView(message: "User rejected")
}
