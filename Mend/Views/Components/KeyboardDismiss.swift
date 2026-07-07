import SwiftUI
import UIKit

extension View {
    /// Programmatically resign first responder (dismiss the keyboard).
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }

    /// Dismiss the keyboard when the user taps anywhere on this view.
    /// Uses a simultaneous gesture so it doesn't block scrolling or buttons.
    func dismissKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}