//
//  PanicRoomViewModel.swift
//  Mend
//

import SwiftUI
import Observation
import AVFoundation

@Observable
class PanicRoomViewModel {
    var ventText = ""
    var doodleLines: [DoodleLine] = []
    var quoteIndex = 0
    var isPlayingMusic = false
    var showContactPicker = false

    private let calmSoundName = "Nervous System Regulation (999 Hz) 1 hour handpan music Malte Marten - Malte Marten (128k)"
    private let calmSoundExtension = "mp3"
    private var audioPlayer: AVAudioPlayer?
    
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

    func clearVentText() {
        ventText = ""
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
        if isPlayingMusic {
            stopCalmSound()
        } else {
            startCalmSound()
        }
        isPlayingMusic.toggle()
    }

    private func startCalmSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            guard let url = Bundle.main.url(forResource: calmSoundName, withExtension: calmSoundExtension) else {
                isPlayingMusic = false
                return
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.75
            player.prepareToPlay()
            player.play()
            audioPlayer = player
        } catch {
            isPlayingMusic = false
        }
    }

    private func stopCalmSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
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