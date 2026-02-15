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
    static let googlePlacesAPIKey = "0f1b2488cc812ae4c8a58c3c76abac888b4bab87"

    static var isGooglePlacesConfigured: Bool {
        googlePlacesAPIKey != "0f1b2488cc812ae4c8a58c3c76abac888b4bab87" && !googlePlacesAPIKey.isEmpty
    }
}
