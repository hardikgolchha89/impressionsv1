//
//  GooglePlacesService.swift
//  impressionsv1
//
//  Handles Google Places Autocomplete + Photo API calls
//

import Foundation
import Combine

// MARK: - API Response Models

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
}

struct FormattedText: Codable {
    let text: String?
}

struct StructuredFormat: Codable {
    let mainText: FormattedText?
    let secondaryText: FormattedText?
}

struct PlaceDetailsResponse: Codable {
    let photos: [PlacePhoto]?
}

struct PlacePhoto: Codable {
    let name: String?
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

    // MARK: - Search

    func search(query: String) {
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
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            do {
                var results = try await GooglePlacesAPI.autocomplete(query: trimmed)
                guard !Task.isCancelled else { return }

                // Fetch photos in parallel (nonisolated, so truly concurrent)
                results = await withTaskGroup(of: (Int, URL?).self) { group in
                    for (index, place) in results.enumerated() {
                        if let placeId = place.googlePlaceId {
                            group.addTask {
                                let url = try? await GooglePlacesAPI.firstPhotoURL(placeId: placeId)
                                return (index, url)
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
                            location: place.location,
                            googlePlaceId: place.googlePlaceId,
                            imageURL: place.imageURL,
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

    func clear() {
        searchTask?.cancel()
        searchResults = []
        isSearching = false
    }

    // MARK: - Photo by name (for popular places without a stored placeId)

    /// Autocomplete by name → get placeId → fetch photo. Fully concurrent.
    func fetchPhotoURLByName(_ name: String) async -> URL? {
        guard AppConfig.isGooglePlacesConfigured else { return nil }
        do {
            let results = try await GooglePlacesAPI.autocomplete(query: name)
            guard let placeId = results.first?.googlePlaceId else { return nil }
            return try await GooglePlacesAPI.firstPhotoURL(placeId: placeId)
        } catch {
            return nil
        }
    }

    // MARK: - Fallback (no API key)

    private func fallbackSearch(_ query: String) -> [Place] {
        let hardcoded = [
            Place(name: "The Bombay Canteen", location: "Lower Parel, Mumbai", imageURL: "fork.knife"),
            Place(name: "Lake View Cafe", location: "Powai, Mumbai", imageURL: "cup.and.saucer.fill"),
            Place(name: "Bastian - At the Top", location: "Worli, Mumbai", imageURL: "building.2.fill"),
            Place(name: "Boneto Fine Dine", location: "Bandra, Mumbai", imageURL: "wineglass.fill"),
            Place(name: "Bandra Born", location: "Bandra West, Mumbai", imageURL: "sparkles"),
            Place(name: "Nksha", location: "Kala Ghoda, Mumbai", imageURL: "leaf.fill"),
            Place(name: "Tanatan Shivaji Park", location: "Dadar, Mumbai", imageURL: "flame.fill"),
            Place(name: "Delhi Darbar", location: "Colaba, Mumbai", imageURL: "building.fill"),
            Place(name: "Kyani & Co.", location: "Marine Lines, Mumbai", imageURL: "cup.and.saucer"),
        ]
        return hardcoded.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}

// MARK: - Pure API layer (no actor isolation — safe to call from task groups)

enum GooglePlacesAPI {
    private static let session = URLSession.shared

    /// Google Places Autocomplete (New)
    static func autocomplete(query: String) async throws -> [Place] {
        print("🔍 [Places] Autocomplete: \"\(query)\"")
        let url = URL(string: "https://places.googleapis.com/v1/places:autocomplete")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.googlePlacesAPIKey, forHTTPHeaderField: "X-Goog-Api-Key")

        let body: [String: Any] = [
            "input": query,
            "includedPrimaryTypes": ["restaurant", "cafe", "bar", "bakery", "meal_takeaway"]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "(unreadable)"
            print("❌ [Places] Autocomplete HTTP \(statusCode) for \"\(query)\": \(body)")
            return []
        }

        let decoded = try JSONDecoder().decode(PlacesAutocompleteResponse.self, from: data)
        let places = (decoded.suggestions ?? []).compactMap { suggestion -> Place? in
            guard let prediction = suggestion.placePrediction else { return nil }
            let name = prediction.structuredFormat?.mainText?.text ?? prediction.text?.text ?? "Unknown"
            let location = prediction.structuredFormat?.secondaryText?.text
            return Place(name: name, location: location, googlePlaceId: prediction.placeId, imageURL: "mappin.circle.fill")
        }
        print("✅ [Places] Autocomplete \"\(query)\" → \(places.count) results: \(places.prefix(3).map(\.name))")
        return places
    }

    /// Fetch the first photo URL for a placeId via Places Details + Photo Media URL.
    static func firstPhotoURL(placeId: String) async throws -> URL? {
        print("📸 [Places] Fetching photo for placeId: \(placeId.prefix(20))…")
        let url = URL(string: "https://places.googleapis.com/v1/places/\(placeId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(AppConfig.googlePlacesAPIKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("photos", forHTTPHeaderField: "X-Goog-FieldMask")

        let (data, response) = try await session.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "(unreadable)"
            print("❌ [Places] Details HTTP \(statusCode) for \(placeId.prefix(20)): \(body)")
            return nil
        }

        let details = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
        let photoCount = details.photos?.count ?? 0
        guard let photoName = details.photos?.first?.name, !photoName.isEmpty else {
            print("⚠️ [Places] No photos returned for \(placeId.prefix(20)) (photos array count: \(photoCount))")
            if let raw = String(data: data, encoding: .utf8) { print("   Raw: \(raw.prefix(300))") }
            return nil
        }

        let encoded = photoName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? photoName
        let photoURLString = "https://places.googleapis.com/v1/\(encoded)/media?maxWidthPx=400&skipHttpRedirect=false&key=\(AppConfig.googlePlacesAPIKey)"
        print("✅ [Places] Photo URL built for \(placeId.prefix(20)): \(photoURLString.prefix(80))…")
        return URL(string: photoURLString)
    }
}
