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
    static let googlePlacesAPIKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE"

    static var isGooglePlacesConfigured: Bool {
        googlePlacesAPIKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE" && !googlePlacesAPIKey.isEmpty
    }
}
