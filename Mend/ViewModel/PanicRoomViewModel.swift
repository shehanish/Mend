//
//  PanicRoomViewModel.swift
//  Mend
//

import SwiftUI
import Observation

@Observable
class PanicRoomViewModel {
    var ventText = ""
    var doodleLines: [DoodleLine] = []
    var quoteIndex = 0
    var isPlayingMusic = false
    var showContactPicker = false
    
    let quotes = [
        "Take it one breath at a time.",
        "This feeling will pass.",
        "You are safe here.",
        "You are stronger than this moment.",
        "It's okay to feel this way. Be gentle with yourself."
    ]
    
    var currentQuote: String {
        quotes[quoteIndex]
    }
    
    func nextQuote() {
        quoteIndex = (quoteIndex + 1) % quotes.count
    }
    
    func clearDoodles() {
        doodleLines.removeAll()
    }
    
    func addDoodlePoint(_ point: CGPoint, isNew: Bool) {
        if isNew {
            doodleLines.append(DoodleLine(points: [point], color: .sageGreen, lineWidth: 5))
        } else {
            let index = doodleLines.count - 1
            if index >= 0 {
                doodleLines[index].points.append(point)
            }
        }
    }
    
    func toggleMusic() {
        isPlayingMusic.toggle()
        // Here you would add logic to actually start/stop AVFoundation music
    }
    
    func callEmergency(_ number: String) {
        if let url = URL(string: "tel://\(number)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func textEmergency(_ number: String) {
        if let url = URL(string: "sms://\(number)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}