//
//  AIInsightBubbleView.swift
//  Mend
//
//  Created by Shehani Hansika on 13.05.26.
//


import SwiftUI

struct AIInsightBubbleView: View {
    let text: String
    var avatarSystemImage: String = "bubu"

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Image("bubu" )
                .resizable()
                .scaledToFit()
                .scaleEffect(1.6) 
                .foregroundStyle(Color.brandPrimary)
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.textOnPrimary)
                .padding(12)
                .background(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.brandPrimary.opacity(0.35), lineWidth: 1)
                       
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: 350, alignment: .leading)
        .padding(.horizontal)
    }
}


