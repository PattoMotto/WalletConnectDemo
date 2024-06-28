import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.primary.colorInvert()
            Text("LOGO")
                .font(.largeTitle)
                .foregroundStyle(.primary)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    SplashView()
}
