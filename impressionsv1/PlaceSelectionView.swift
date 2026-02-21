//
//  PlaceSelectionView.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI

// MARK: - Data Model
struct Place: Identifiable {
    let id: UUID
    let name: String
    let imageURL: String
    let location: String?
    let googlePlaceId: String?
    let photoURL: URL?

    init(id: UUID = UUID(), name: String, imageURL: String, location: String? = nil, googlePlaceId: String? = nil, photoURL: URL? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.location = location
        self.googlePlaceId = googlePlaceId
        self.photoURL = photoURL
    }
}

// MARK: - Grain Texture Overlay

/// A subtle grain texture rendered via Canvas — gives the dark cards that film/material feel.
struct GrainTextureView: View {
    var opacity: Double = 0.06

    var body: some View {
        Canvas { context, size in
            let grainSize: CGFloat = 1.0
            let cols = Int(size.width / grainSize) + 1
            let rows = Int(size.height / grainSize) + 1

            // Use a deterministic seed for stable grain (no animation flicker)
            var rng = SeededRNG(seed: 42)

            for row in 0..<rows {
                for col in 0..<cols {
                    let brightness = rng.nextDouble()
                    let x = CGFloat(col) * grainSize
                    let y = CGFloat(row) * grainSize
                    let rect = CGRect(x: x, y: y, width: grainSize, height: grainSize)
                    context.fill(
                        Path(rect),
                        with: .color(Color.white.opacity(brightness * opacity))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

/// Simple seeded LCG RNG for deterministic grain
struct SeededRNG {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }

    mutating func nextDouble() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }
}

// MARK: - iOS Squircle Shape

/// Replicates the iOS continuous corner curve (squircle) for authentic feel.
struct Squircle: Shape {
    var cornerRadius: CGFloat
    var smoothing: CGFloat = 0.6   // 0 = standard rounded rect, ~0.6 = iOS default

    func path(in rect: CGRect) -> Path {
        // Use SwiftUI's built-in continuous curve via UIBezierPath (exact iOS squircle)
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - View
struct PlaceSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @StateObject private var placesService = GooglePlacesService()
    @State private var selectedPlace: Place? = nil
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    @State private var popularPlaces: [Place] = [
        Place(name: "The Bombay Canteen", imageURL: "fork.knife", location: "Lower Parel, Mumbai"),
        Place(name: "Lake View Cafe", imageURL: "cup.and.saucer.fill", location: "Powai, Mumbai"),
        Place(name: "Bastian", imageURL: "building.2.fill", location: "Worli, Mumbai"),
        Place(name: "Boneto Fine Dine", imageURL: "wineglass.fill", location: "Bandra, Mumbai"),
        Place(name: "Bandra Born", imageURL: "sparkles", location: "Bandra West"),
        Place(name: "Nksha", imageURL: "leaf.fill", location: "Kala Ghoda"),
        Place(name: "Tanatan", imageURL: "flame.fill", location: "Dadar, Mumbai"),
        Place(name: "Delhi Darbar", imageURL: "building.fill", location: "Colaba, Mumbai"),
        Place(name: "Kyani & Co.", imageURL: "cup.and.saucer", location: "Marine Lines"),
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var isActivelySearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "131313")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Header
                HStack(alignment: .center) {
                    Button(action: { coordinator.goBack() }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "232323"))
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .frame(width: 36, height: 36)

                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()

                    Text("Where did you go?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // Balance spacer
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                // MARK: Search Bar
                searchBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                // MARK: Content
                if isActivelySearching {
                    searchResultsList
                } else {
                    popularPlacesGrid
                }

                // MARK: Continue Button
                continueButton
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: searchText) { oldValue, newValue in
            selectedPlace = nil
            placesService.search(query: newValue)
        }
        .task {
            await fetchPopularPhotos()
        }
    }

    // Fetch Google Maps photos for popular places in parallel
    private func fetchPopularPhotos() async {
        guard AppConfig.isGooglePlacesConfigured else {
            print("⚠️ [PlaceSelection] Google Places not configured, skipping photo fetch")
            return
        }
        print("🚀 [PlaceSelection] Starting photo fetch for \(popularPlaces.count) popular places")

        // Snapshot names/indices before entering the task group
        let snapshot = popularPlaces.enumerated().map { ($0.offset, $0.element) }

        let photos: [(Int, URL)] = await withTaskGroup(of: (Int, URL?).self) { group in
            for (index, place) in snapshot {
                group.addTask {
                    // GooglePlacesAPI is not actor-isolated, so this runs truly concurrently
                    do {
                        let results = try await GooglePlacesAPI.autocomplete(query: place.name)
                        guard let placeId = results.first?.googlePlaceId else { return (index, nil) }
                        let url = try await GooglePlacesAPI.firstPhotoURL(placeId: placeId)
                        return (index, url)
                    } catch {
                        return (index, nil)
                    }
                }
            }
            var collected: [(Int, URL)] = []
            for await (index, url) in group {
                if let url { collected.append((index, url)) }
            }
            return collected
        }

        print("🏁 [PlaceSelection] Photo fetch complete — got \(photos.count)/\(popularPlaces.count) photos")

        // Apply results back on main actor
        for (index, url) in photos {
            let place = popularPlaces[index]
            popularPlaces[index] = Place(
                id: place.id,
                name: place.name,
                imageURL: place.imageURL,
                location: place.location,
                googlePlaceId: place.googlePlaceId,
                photoURL: url
            )
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.white.opacity(0.35))

            TextField("", text: $searchText, prompt:
                Text("Search restaurants, cafes…")
                    .foregroundColor(Color.white.opacity(0.3))
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isSearchFocused)

            if placesService.isSearching {
                ProgressView()
                    .tint(Color.white.opacity(0.4))
                    .scaleEffect(0.75)
            } else if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    placesService.clear()
                    selectedPlace = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            ZStack {
                // Card base
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "242424"))

                // Grain
                GrainTextureView(opacity: 0.05)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Outline
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }

    // MARK: - Popular Places Grid

    private var popularPlacesGrid: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                // Section label
                Text("POPULAR SPOTS")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundColor(Color.white.opacity(0.3))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(popularPlaces) { place in
                        PlaceCard(
                            place: place,
                            isSelected: selectedPlace?.id == place.id
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if selectedPlace?.id == place.id {
                                    selectedPlace = nil
                                } else {
                                    selectedPlace = place
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Search Results List

    private var searchResultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if placesService.searchResults.isEmpty && !placesService.isSearching {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundColor(Color.white.opacity(0.2))

                        Text("No places found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.4))

                        Text("Try a different search")
                            .font(.system(size: 13))
                            .foregroundColor(Color.white.opacity(0.25))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(placesService.searchResults) { place in
                        PlaceResultRow(
                            place: place,
                            isSelected: selectedPlace?.id == place.id
                        ) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if selectedPlace?.id == place.id {
                                    selectedPlace = nil
                                } else {
                                    selectedPlace = place
                                    isSearchFocused = false
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        VStack(spacing: 0) {
            // Soft fade above button
            LinearGradient(
                colors: [Color(hex: "131313").opacity(0), Color(hex: "131313")],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            .allowsHitTesting(false)

            if let place = selectedPlace {
                Button(action: {
                    coordinator.completePlace(place: place)
                }) {
                    HStack(spacing: 8) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                            GrainTextureView(opacity: 0.04)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                Color.clear.frame(height: 52 + 32)
            }
        }
        .background(Color(hex: "131313"))
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedPlace?.id)
    }
}

// MARK: - Place Card

struct PlaceCard: View {
    let place: Place
    let isSelected: Bool
    let onTap: () -> Void

    // Stable per-card color tint drawn from the name hash
    private var cardTint: Color {
        let tints: [Color] = [
            Color(hex: "2A2420"),
            Color(hex: "1E2428"),
            Color(hex: "22261E"),
            Color(hex: "26201E"),
            Color(hex: "1E2226"),
        ]
        let index = abs(place.name.hashValue) % tints.count
        return tints[index]
    }

    var body: some View {
        VStack(spacing: 8) {
            // Card tile
            ZStack(alignment: .topTrailing) {
                // Background layers
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            isSelected
                                ? Color(hex: "2C2C2C")
                                : cardTint
                        )

                    // Grain
                    GrainTextureView(opacity: isSelected ? 0.04 : 0.07)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    // Border
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            isSelected
                                ? LinearGradient(
                                    colors: [Color.white.opacity(0.35), Color.white.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.white.opacity(0.10), Color.white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: 1
                        )

                    // Photo or icon fallback
                    if let photoURL = place.photoURL {
                        AsyncImage(url: photoURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                            case .failure(let error):
                                let _ = print("❌ [AsyncImage] Failed for \(place.name): \(error.localizedDescription) url=\(photoURL)")
                                Image(systemName: place.imageURL)
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundColor(Color.white.opacity(0.45))
                                    .symbolRenderingMode(.monochrome)
                            case .empty:
                                Image(systemName: place.imageURL)
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundColor(Color.white.opacity(0.45))
                                    .symbolRenderingMode(.monochrome)
                            @unknown default:
                                Image(systemName: place.imageURL)
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundColor(Color.white.opacity(0.45))
                            }
                        }
                    } else {
                        Image(systemName: place.imageURL)
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(
                                isSelected
                                    ? Color.white.opacity(0.9)
                                    : Color.white.opacity(0.45)
                            )
                            .symbolRenderingMode(.monochrome)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .clipped()

                // Selection checkmark
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(8)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            // Label
            Text(place.name)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Color.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .scaleEffect(isSelected ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.65), value: isSelected)
    }
}

// MARK: - Search Result Row

struct PlaceResultRow: View {
    let place: Place
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Icon bubble
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white : Color(hex: "242424"))
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected
                                        ? Color.clear
                                        : Color.white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                        .frame(width: 40, height: 40)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    } else if let photoURL = place.photoURL {
                        AsyncImage(url: photoURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                            default:
                                Image(systemName: "mappin")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                        }
                    } else {
                        Image(systemName: "mappin")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                }

                // Name + location
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if let location = place.location {
                        Text(location)
                            .font(.system(size: 12))
                            .foregroundColor(Color.white.opacity(0.35))
                            .lineLimit(1)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? Color(hex: "242424")
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    : nil
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, isSelected ? 8 : 0)
        .padding(.vertical, isSelected ? 2 : 0)
    }
}

#Preview {
    PlaceSelectionView(coordinator: CreateImpressionCoordinator())
}
