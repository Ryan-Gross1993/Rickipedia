//
//  Color+Rickipedia.swift
//  Rickipedia
//
//  Created by Rai Gross on 4/17/26.
//

import SwiftUI
import UIKit

private extension UIColor {
    convenience init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255,
            green: CGFloat((value & 0x00FF00) >> 8) / 255,
            blue: CGFloat(value & 0x0000FF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    static let rmPortalGreen = Color(UIColor(hex: "97CE4C"))
    static let rmRickBlue = Color(UIColor(hex: "35C9DD"))
    static let rmMortyYellow = Color(UIColor(hex: "F0E14A"))
    static let rmNeonGlow = Color(UIColor(hex: "A9F3FD"))

    static let rmBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "0F1C2E")
            : UIColor(hex: "F8F4E9")
    })

    static let rmSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "1C2526")
            : UIColor(hex: "FFFFFF")
    })

    static let rmTextPrimary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "F0EDE4")
            : UIColor(hex: "1A1A1A")
    })

    static let rmTextSecondary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "A5D6FF")
            : UIColor(hex: "2A3A4A")
    })

    static let rmAccent = Color.rmPortalGreen
}
