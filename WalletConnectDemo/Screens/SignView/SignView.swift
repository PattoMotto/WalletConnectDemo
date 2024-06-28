import SwiftUI

struct SignView: View {
    @ObservedObject var viewModel: SignViewModel

    var body: some View {
        VStack {
            Text(viewModel.uri.absoluteString)
            Button("Copy link") {
                viewModel.copyToPasteboard()
            }
        }
    }
}
