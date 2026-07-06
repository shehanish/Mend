import SwiftUI

struct WelcomeView: View {
    @State private var showAuthSheet = false
    
    var body: some View {
        ZStack {
            Color.appBackgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 260, height: 260)
                .blur(radius: 24)
                .offset(x: 130, y: -260)

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 28)
                .offset(x: -140, y: 230)
            
            VStack(spacing: 0) {
                Spacer(minLength: 28)

                VStack(spacing: 16) {
                    Text("Mend")
                        .font(.system(size: 54, weight: .heavy))
                        .foregroundStyle(Color.textOnPrimary)
                        .kerning(1.5)

                    Text("A softer place to heal, track, and come back to yourself.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.textOnPrimary.opacity(0.78))
                        .padding(.horizontal, 36)
                }
                
                Spacer(minLength: 22)
                
                VStack(spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .fill(Color.white.opacity(0.30))
                            .overlay(
                                RoundedRectangle(cornerRadius: 36, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 12)
                        
                        BlobAvatarView(width: 220, height: 160, animate: true)
                            .padding(.vertical, 18)
                    }
                    .padding(.horizontal, 28)

                    VStack(spacing: 12) {
                        Text("Start your healing journey")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.textOnPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("Track your days, understand your feelings, and find support that feels human.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.textOnPrimary.opacity(0.80))
                            .padding(.horizontal, 32)
                    }

                    HStack(spacing: 5) {
                        TagPill(title: "Daily check-ins")
                        TagPill(title: "Gentle support")
                        TagPill(title: "Private space")
                    }
                    .padding(.horizontal, 24)
                }

                Spacer(minLength: 18)

                Button(action: {
                    showAuthSheet = true
                }) {
                    HStack(spacing: 10) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandPrimary.opacity(0.82)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.brandPrimary.opacity(0.22), radius: 14, x: 0, y: 10)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 44)
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct TagPill: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.textOnPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.26))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
    }
}

#Preview {
    WelcomeView()
}
