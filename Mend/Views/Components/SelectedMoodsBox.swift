//
//  SelectedMoodsBox.swift
//  Mend
//
//  Created by Shehani Hansika on 07.05.26.
//


import SwiftUI

struct SelectedMoodsBox: View {
    let selectedMoods: [String]

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            if selectedMoods.isEmpty {
                Text("Pick one or more feelings above.")
                    .font(.footnote)
                    .foregroundStyle(Color.brandPrimary.opacity(0.6))
            } else {
                // Horizontal wrap-ish: will line-break naturally on iOS 16+ using Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 2) {
                    ForEach(selectedMoods, id: \.self) { mood in
                        Text(mood)
                            .font(.footnote)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color.sageGreen.opacity(1.0))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            
                    }
                    
                }
            }
        }
        
        .padding(14)
        .background(.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    SelectedMoodsBox(selectedMoods: [])
}
