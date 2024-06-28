import Foundation

class AppViewModel: ObservableObject {
    @Published var screen: Screen
    
    init(screen: Screen = .splash) {
        self.screen = screen
    }
    
    private func restoreSession() -> Bool {
        false
    }
}
