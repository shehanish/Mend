import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 40)
                Text(message.text)
                    .padding(14)
                    .background(Color.brandPrimary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    // Nice tailored corners for user message
                    .cornerRadius(4, corners: [.bottomRight])
            } else {
                Image("bubu") // Using the same avatar icon
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.4) 
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .padding(.bottom, 6)

                Text(message.text)
                    .padding(14)
                    .background(Color.sageGreen.opacity(0.15))
                    .foregroundColor(Color.textOnPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    // Nice tailored corners for AI message
                    .cornerRadius(4, corners: [.bottomLeft])
                Spacer(minLength: 40)
            }
        }
    }
}

// View extension to selectively round specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
