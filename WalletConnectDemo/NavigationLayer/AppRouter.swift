import Foundation
import SwiftUI

class AppRouter {    
    private let viewModel = AppViewModel()

    @ViewBuilder
    func view() -> some View {
        AppView(viewModel: viewModel)
    }
    
    func handleDeeplink() {
        
    }
}
