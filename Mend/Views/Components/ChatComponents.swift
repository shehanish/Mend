import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 30)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.senderName)
                        .font(.caption2)
                        .foregroundStyle(Color.brandPrimary.opacity(0.7))

                    Text(message.text)
                        .padding(14)
                        .background(Color.brandPrimary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .cornerRadius(4, corners: [.bottomRight])
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.senderName)
                        .font(.caption2)
                        .foregroundStyle(Color.brandPrimary.opacity(0.7))

                    HStack(alignment: .center, spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.92))
                                .overlay(
                                    Circle()
                                        .stroke(Color.brandPrimary.opacity(0.18), lineWidth: 1)
                                )
                                .frame(width: 36, height: 36)

                            BlobAvatarView(width: 22, height: 18, showShadow: false)
                                .frame(width: 36, height: 36, alignment: .center)
                                .offset(y: -1)
                        }

                        Text(message.text)
                            .padding(14)
                            .background(Color.sageGreen.opacity(0.15))
                            .foregroundColor(Color.textOnPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .cornerRadius(4, corners: [.bottomLeft])
                        Spacer(minLength: 40)
                    }
                }
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
