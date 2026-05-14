//
//  DesignSystem.swift
//  Senso
//

import SwiftUI

enum SensoColor {
    static let primary = Color(red: 0/255, green: 35/255, blue: 111/255)
    static let onPrimary = Color.white
    static let primaryContainer = Color(red: 30/255, green: 58/255, blue: 138/255)
    static let onPrimaryContainer = Color(red: 144/255, green: 168/255, blue: 255/255)
    static let primaryFixed = Color(red: 220/255, green: 225/255, blue: 255/255)
    static let primaryFixedDim = Color(red: 182/255, green: 196/255, blue: 255/255)

    static let surfaceBright = Color(red: 247/255, green: 249/255, blue: 251/255)
    static let surfaceContainer = Color(red: 236/255, green: 238/255, blue: 240/255)
    static let surfaceContainerLow = Color(red: 242/255, green: 244/255, blue: 246/255)
    static let surfaceContainerHigh = Color(red: 230/255, green: 232/255, blue: 234/255)
    static let onSurface = Color(red: 25/255, green: 28/255, blue: 30/255)
    static let onSurfaceVariant = Color(red: 68/255, green: 70/255, blue: 81/255)

    static let secondary = Color(red: 86/255, green: 94/255, blue: 116/255)
    static let secondaryContainer = Color(red: 218/255, green: 226/255, blue: 253/255)

    static let outline = Color(red: 117/255, green: 118/255, blue: 130/255)
    static let outlineVariant = Color(red: 197/255, green: 197/255, blue: 211/255)

    static let error = Color(red: 186/255, green: 26/255, blue: 26/255)
    static let onError = Color.white
}

enum SensoFont {
    static let headlineLg = Font.system(size: 32, weight: .heavy)
    static let headlineLgMobile = Font.system(size: 28, weight: .heavy)
    static let headlineMd = Font.system(size: 24, weight: .bold)
    static let bodyLg = Font.system(size: 20, weight: .regular)
    static let bodyMd = Font.system(size: 18, weight: .regular)
    static let labelXl = Font.system(size: 18, weight: .bold)
    static let labelMd = Font.system(size: 16, weight: .semibold)
}
