import SwiftUI

struct WelcomeView: View {
    @State private var showAuthSheet = false
    
    var body: some View {
        ZStack {
            Color.appBackgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image("bubu") // Placeholder for illustration
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                
                Text("Start Your Healing Journey")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.textOnPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Track your days, understand your feelings, and find support.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textOnPrimary.opacity(0.8))
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    showAuthSheet = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    WelcomeView()
}
