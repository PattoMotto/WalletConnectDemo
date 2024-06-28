import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel: WalletViewModel
    
    var body: some View {
        HStack {
            if let addressId = viewModel.addressId {
                Text("Address: ")
                    .font(.title2)
                Text(addressId)
                    .font(.title)
            }
        }
    }
}
