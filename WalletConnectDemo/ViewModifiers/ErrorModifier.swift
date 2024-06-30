import Foundation
import SwiftUI

class ErrorModifierViewModel {
    @Published var message: String?
    let onDisappear: () -> Void
    
    init(error: AppError?, onDisappear: @escaping () -> Void) {
        self.message = error?.localizedDescription
        self.onDisappear = onDisappear
    }

    func errorDidAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.errorDuration) {
            self.message = nil
            self.onDisappear()
        }
    }
}

struct ErrorModifier: ViewModifier {
    let viewModel: ErrorModifierViewModel

    func body(content: Content) -> some View {
        if let message = viewModel.message {
            ZStack {
                content

                VStack {
                    ErrorView(message: message)
                        .onAppear {
                            viewModel.errorDidAppear()
                        }

                    Spacer()
                }
            }
        } else {
            content
        }
    }
}

extension View {
    func showError(error: AppError?, onDisappear: @escaping () -> Void) -> some View {
        modifier(
            ErrorModifier(
                viewModel: ErrorModifierViewModel(
                    error: error,
                    onDisappear: onDisappear
                )
            )
        )
    }
}
