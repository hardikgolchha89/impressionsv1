//
//  GooglePlacesService.swift
//  impressionsv1
//
//  Handles Google Places Autocomplete API calls
//

import Foundation
import Combine

// MARK: - API Response Models

/// Google Places Autocomplete response
struct PlacesAutocompleteResponse: Codable {
    let suggestions: [Suggestion]?
}

struct Suggestion: Codable {
    let placePrediction: PlacePrediction?
}

struct PlacePrediction: Codable {
    let placeId: String?
    let text: FormattedText?
    let structuredFormat: StructuredFormat?

    enum CodingKeys: String, CodingKey {
        case placeId
        case text
        case structuredFormat
    }
}

struct FormattedText: Codable {
    let text: String?
}

struct StructuredFormat: Codable {
    let mainText: FormattedText?
    let secondaryText: FormattedText?
}

// MARK: - Google Places Service

@MainActor
class GooglePlacesService: ObservableObject {
    @Published var searchResults: [Place] = []
    @Published var isSearching = false

    private var searchTask: Task<Void, Never>?
    private let session = URLSession.shared

    /// Search for places using Google Places Autocomplete (New) API
    func search(query: String) {
        // Cancel any in-flight search
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            print("🔍 Search cleared (empty query)")
            searchResults = []
            isSearching = false
            return
        }

        guard AppConfig.isGooglePlacesConfigured else {
            // Fallback: return filtered hardcoded results when no API key
            print("⚠️ Google Places API not configured, using fallback search for: \"\(trimmed)\"")
            searchResults = fallbackSearch(trimmed)
            print("📍 Fallback results: \(searchResults.count) places")
            return
        }

        print("🔍 Starting search for: \"\(trimmed)\"")
        isSearching = true

        searchTask = Task {
            // Debounce: wait 300ms so we don't fire on every keystroke
            try? await Task.sleep(nanoseconds: 300_000_000)

            guard !Task.isCancelled else {
                print("⏹️ Search cancelled for: \"\(trimmed)\"")
                return
            }

            do {
                let results = try await fetchAutocomplete(query: trimmed)
                if !Task.isCancelled {
                    print("✅ Found \(results.count) places for: \"\(trimmed)\"")
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                if !Task.isCancelled {
                    print("❌ Places search error for \"\(trimmed)\": \(error)")
                    self.searchResults = []
                    self.isSearching = false
                }
            }
        }
    }

    /// Clear search results
    func clear() {
        searchTask?.cancel()
        searchResults = []
        isSearching = false
    }

    // MARK: - Private

    private func fetchAutocomplete(query: String) async throws -> [Place] {
        let url = URL(string: "https://places.googleapis.com/v1/places:autocomplete")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.googlePlacesAPIKey, forHTTPHeaderField: "X-Goog-Api-Key")

        // Request body — filter to food/drink establishments (max 5 types allowed)
        let body: [String: Any] = [
            "input": query,
            "includedPrimaryTypes": [
                "restaurant",
                "cafe",
                "bar",
                "bakery",
                "meal_takeaway"
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("🌐 Calling Google Places API...")
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            return []
        }

        print("📡 API Response: HTTP \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ API Error Response: \(responseString)")
            }
            // On error, return empty rather than crash
            return []
        }

        let decoded = try JSONDecoder().decode(PlacesAutocompleteResponse.self, from: data)
        let suggestionCount = decoded.suggestions?.count ?? 0
        print("📝 Decoded \(suggestionCount) suggestions from API")

        let places = (decoded.suggestions ?? []).compactMap { suggestion -> Place? in
            guard let prediction = suggestion.placePrediction else { return nil }

            let name = prediction.structuredFormat?.mainText?.text
                ?? prediction.text?.text
                ?? "Unknown"

            let location = prediction.structuredFormat?.secondaryText?.text

            return Place(
                name: name,
                imageURL: "mappin.circle.fill",
                location: location,
                googlePlaceId: prediction.placeId
            )
        }

        print("🏪 Mapped to \(places.count) Place objects")
        return places
    }

    /// Fallback search against hardcoded places (when no API key)
    private func fallbackSearch(_ query: String) -> [Place] {
        let hardcoded = [
            Place(name: "The Bombay Canteen", imageURL: "fork.knife", location: "Lower Parel, Mumbai"),
            Place(name: "Lake View Cafe", imageURL: "cup.and.saucer.fill", location: "Powai, Mumbai"),
            Place(name: "Bastian - At the Top", imageURL: "building.2.fill", location: "Worli, Mumbai"),
            Place(name: "Boneto Fine Dine", imageURL: "wineglass.fill", location: "Bandra, Mumbai"),
            Place(name: "Bandra Born", imageURL: "sparkles", location: "Bandra West, Mumbai"),
            Place(name: "Nksha", imageURL: "leaf.fill", location: "Kala Ghoda, Mumbai"),
            Place(name: "Tanatan Shivaji Park", imageURL: "flame.fill", location: "Dadar, Mumbai"),
            Place(name: "Delhi Darbar", imageURL: "building.fill", location: "Colaba, Mumbai"),
            Place(name: "Kyani & Co.", imageURL: "cup.and.saucer", location: "Marine Lines, Mumbai"),
        ]

        return hardcoded.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}
