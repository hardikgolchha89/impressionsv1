//
//  AppConfig.swift
//  impressionsv1
//
//  API keys and configuration
//

import Foundation

enum AppConfig {
    // MARK: - Google Places API
    // Get your key at: https://console.cloud.google.com/apis/credentials
    // Enable "Places API (New)" in your project
    // Format should be: AIzaSy... (not a private RSA key!)
    static let googlePlacesAPIKey = "AIzaSyBry303Z-Jkq2KPks-y_HwM63AuxAS8yYk"

    static var isGooglePlacesConfigured: Bool {
        !googlePlacesAPIKey.isEmpty && googlePlacesAPIKey.hasPrefix("AIza")
    }
}
