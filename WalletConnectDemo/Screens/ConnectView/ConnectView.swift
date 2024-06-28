import SwiftUI

struct ConnectView: View {
    @ObservedObject var viewModel: ConnectViewModel

    var body: some View {
        Button("Connect") {
            viewModel.onTapConnect()
        }
    }
}
