//
//  PlaceSelectionView.swift
//  impressionsv1
//

import SwiftUI

struct PlaceSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @StateObject private var placesService = GooglePlacesService()
    @State private var searchText = ""
    @State private var selectedPlace: Place? = nil
    @State private var isTyping = false

    private let popularPlaces: [Place] = [
        Place(id: "1", name: "The Bombay Canteen",  location: "Lower Parel", cuisine: "Modern Indian"),
        Place(id: "2", name: "Bastian",             location: "Bandra",      cuisine: "Seafood & Grill"),
        Place(id: "3", name: "Trishna",             location: "Fort",        cuisine: "Coastal Seafood"),
        Place(id: "4", name: "Burma Burma",         location: "Fort",        cuisine: "Burmese"),
        Place(id: "5", name: "Pali Village Cafe",   location: "Bandra",      cuisine: "All Day Cafe"),
        Place(id: "6", name: "Social Worli",        location: "Worli",       cuisine: "Bar & Kitchen"),
        Place(id: "7", name: "Masque",              location: "Mahalaxmi",   cuisine: "Progressive Indian"),
        Place(id: "8", name: "Cafe Mondegar",       location: "Colaba",      cuisine: "Continental"),
    ]

    /// What to display: live results if search is active, else popular list
    private var displayedPlaces: [Place] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return popularPlaces
        }
        if !placesService.searchResults.isEmpty {
            return placesService.searchResults
        }
        // Fallback local filter while waiting for API
        return popularPlaces.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.location ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    private var sectionLabel: String {
        searchText.trimmingCharacters(in: .whitespaces).isEmpty
            ? "POPULAR NEAR YOU"
            : (placesService.isSearching ? "SEARCHING…" : "RESULTS")
    }

    var body: some View {
        ZStack {
            Color.appCream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // ── Header ─────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEW IMPRESSION")
                        .font(.custom("HKGrotesk-SemiBold", size: 11))
                        .foregroundColor(.appOlive)
                        .kerning(0.8)

                    HStack(spacing: 6) {
                        Text("Where did you eat?")
                            .font(.custom("HKGrotesk-Bold", size: 28))
                            .foregroundColor(.appBrown)
                        Text("📍")
                            .font(.system(size: 24))
                    }

                    Text("Search any restaurant, dhaba, or café you visited.")
                        .font(.custom("HKGrotesk-Regular", size: 14))
                        .foregroundColor(.appBrown.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // ── Search bar ─────────────────────────────────────────
                HStack(spacing: 10) {
                    if placesService.isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(Color.appBrown.opacity(0.4))
                            .frame(width: 15, height: 15)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                            .foregroundColor(.appBrown.opacity(0.4))
                    }

                    TextField("Search restaurant, area...", text: $searchText)
                        .font(.custom("HKGrotesk-Regular", size: 15))
                        .foregroundColor(.appBrown)
                        .autocorrectionDisabled()
                        .onChange(of: searchText) { _, newValue in
                            placesService.search(query: newValue)
                        }

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            placesService.clear()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.appBrown.opacity(0.3))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appOffWhite)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // ── Section label ──────────────────────────────────────
                Text(sectionLabel)
                    .font(.custom("HKGrotesk-SemiBold", size: 11))
                    .foregroundColor(.appBrown.opacity(0.4))
                    .kerning(0.8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    .animation(.easeInOut(duration: 0.15), value: sectionLabel)

                // ── Place list ─────────────────────────────────────────
                ScrollView {
                    if displayedPlaces.isEmpty && !placesService.isSearching && !searchText.isEmpty {
                        // No results state
                        VStack(spacing: 12) {
                            Image(systemName: "fork.knife.circle")
                                .font(.system(size: 36))
                                .foregroundColor(.appBrown.opacity(0.2))
                            Text("No places found for \"\(searchText)\"")
                                .font(.custom("HKGrotesk-Regular", size: 14))
                                .foregroundColor(.appBrown.opacity(0.4))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(displayedPlaces) { place in
                                PlaceRow(
                                    place: place,
                                    isSelected: selectedPlace?.id == place.id
                                ) {
                                    withAnimation(.spring(duration: 0.2)) {
                                        selectedPlace = place
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        coordinator.completePlace(place)
                                    }
                                }

                                if place.id != displayedPlaces.last?.id {
                                    Divider()
                                        .background(Color.appBrown.opacity(0.08))
                                        .padding(.leading, 20)
                                }
                            }
                        }
                        .background(Color.appOffWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 20)
                    }
                }

                // ── Maps attribution ───────────────────────────────────
                HStack {
                    Image(systemName: "map")
                        .font(.system(size: 11))
                        .foregroundColor(.appBrown.opacity(0.35))
                    Text("Powered by Google Maps · Any place worldwide")
                        .font(.custom("HKGrotesk-Regular", size: 11))
                        .foregroundColor(.appBrown.opacity(0.35))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
        }
    }
}

// MARK: - Place row

private struct PlaceRow: View {
    let place: Place
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Group {
                    if let photoURL = place.photoURL {
                        AsyncImage(url: photoURL) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 15))
                                    .foregroundColor(isSelected ? .appOlive : .appBrown.opacity(0.4))
                            }
                        }
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 15))
                            .foregroundColor(isSelected ? .appOlive : .appBrown.opacity(0.4))
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? Color.appOlive.opacity(0.15) : Color.appGreige.opacity(0.35))
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.custom("HKGrotesk-SemiBold", size: 15))
                        .foregroundColor(.appBrown)
                    HStack(spacing: 4) {
                        if let loc = place.location, !loc.isEmpty {
                            Text(loc)
                            if let cuisine = place.cuisine, !cuisine.isEmpty {
                                Text("·")
                                Text(cuisine)
                            }
                        } else if let cuisine = place.cuisine, !cuisine.isEmpty {
                            Text(cuisine)
                        }
                    }
                    .font(.custom("HKGrotesk-Regular", size: 12))
                    .foregroundColor(.appBrown.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.appBrown.opacity(0.25))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? Color.appOlive.opacity(0.07) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}
