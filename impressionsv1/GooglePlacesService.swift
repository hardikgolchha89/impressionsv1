//
//  GooglePlacesService.swift
//  impressionsv1
//
//  Handles Google Places Autocomplete + Photo API calls
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

/// Google Places Details response (for fetching photos)
struct PlaceDetailsResponse: Codable {
    let photos: [PlacePhoto]?
}

struct PlacePhoto: Codable {
    let name: String?         // e.g. "places/ChIJ.../photos/AXCi..."
    let widthPx: Int?
    let heightPx: Int?
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
            searchResults = []
            isSearching = false
            return
        }

        guard AppConfig.isGooglePlacesConfigured else {
            searchResults = fallbackSearch(trimmed)
            return
        }

        isSearching = true

        searchTask = Task {
            // Debounce: wait 300ms so we don't fire on every keystroke
            try? await Task.sleep(nanoseconds: 300_000_000)

            guard !Task.isCancelled else { return }

            do {
                var results = try await fetchAutocomplete(query: trimmed)
                guard !Task.isCancelled else { return }

                // Fetch first photo for each result in parallel
                results = await withTaskGroup(of: (Int, URL?).self) { group in
                    for (index, place) in results.enumerated() {
                        if let placeId = place.googlePlaceId {
                            group.addTask {
                                let photoURL = try? await self.fetchFirstPhotoURL(placeId: placeId)
                                return (index, photoURL)
                            }
                        }
                    }

                    var photoMap: [Int: URL] = [:]
                    for await (index, url) in group {
                        if let url { photoMap[index] = url }
                    }

                    return results.enumerated().map { (index, place) in
                        Place(
                            id: place.id,
                            name: place.name,
                            imageURL: place.imageURL,
                            location: place.location,
                            googlePlaceId: place.googlePlaceId,
                            photoURL: photoMap[index]
                        )
                    }
                }

                if !Task.isCancelled {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                if !Task.isCancelled {
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

    // MARK: - Photo fetching (public, for popular places grid)

    /// Fetches the first Google Maps photo URL for a given placeId.
    /// Returns nil if not available.
    func fetchFirstPhotoURL(placeId: String) async throws -> URL? {
        // Step 1: Get place details to obtain the first photo resource name
        let detailsURL = URL(string: "https://places.googleapis.com/v1/places/\(placeId)")!

        var detailsRequest = URLRequest(url: detailsURL)
        detailsRequest.httpMethod = "GET"
        detailsRequest.setValue(AppConfig.googlePlacesAPIKey, forHTTPHeaderField: "X-Goog-Api-Key")
        // Only request the photos field to minimise billing
        detailsRequest.setValue("places.photos", forHTTPHeaderField: "X-Goog-FieldMask")

        let (detailsData, detailsResponse) = try await session.data(for: detailsRequest)

        guard let httpResponse = detailsResponse as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }

        let details = try JSONDecoder().decode(PlaceDetailsResponse.self, from: detailsData)

        guard let photoName = details.photos?.first?.name, !photoName.isEmpty else {
            return nil
        }

        // Step 2: Build the photo media URL (this is a direct URL, no second network call needed)
        // Format: https://places.googleapis.com/v1/{photoName}/media?maxWidthPx=400&key=...
        let encodedName = photoName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? photoName
        let photoURLString = "https://places.googleapis.com/v1/\(encodedName)/media?maxWidthPx=400&skipHttpRedirect=false&key=\(AppConfig.googlePlacesAPIKey)"

        return URL(string: photoURLString)
    }

    /// Searches for a place by name and returns its first photo URL.
    /// Used for popular places (which don't have placeIds stored).
    func fetchPhotoURLByName(_ name: String) async -> URL? {
        guard AppConfig.isGooglePlacesConfigured else { return nil }

        do {
            let results = try await fetchAutocomplete(query: name)
            guard let firstPlace = results.first, let placeId = firstPlace.googlePlaceId else {
                return nil
            }
            return try await fetchFirstPhotoURL(placeId: placeId)
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func fetchAutocomplete(query: String) async throws -> [Place] {
        let url = URL(string: "https://places.googleapis.com/v1/places:autocomplete")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.googlePlacesAPIKey, forHTTPHeaderField: "X-Goog-Api-Key")

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

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return []
        }

        let decoded = try JSONDecoder().decode(PlacesAutocompleteResponse.self, from: data)

        return (decoded.suggestions ?? []).compactMap { suggestion -> Place? in
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
