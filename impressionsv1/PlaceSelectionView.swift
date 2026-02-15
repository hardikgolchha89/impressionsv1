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

    init(id: UUID = UUID(), name: String, imageURL: String, location: String? = nil, googlePlaceId: String? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.location = location
        self.googlePlaceId = googlePlaceId
    }
}

// MARK: - View
struct PlaceSelectionView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @StateObject private var placesService = GooglePlacesService()
    @State private var selectedPlace: Place? = nil
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    // Popular places shown when search is empty
    private let popularPlaces: [Place] = [
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

    // Grid columns for popular places
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    /// Whether we should show search results list vs the popular grid
    private var isActivelySearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { coordinator.goBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Where did you go?")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textTertiary)
                        .padding(.leading, Spacing.sm)

                    TextField("Search restaurants, cafes...", text: $searchText)
                        .font(AppFont.body)
                        .foregroundColor(.textPrimary)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($isSearchFocused)

                    if placesService.isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.trailing, Spacing.sm)
                    } else if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            placesService.clear()
                            selectedPlace = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textTertiary)
                                .padding(.trailing, Spacing.sm)
                        }
                    }
                }
                .frame(height: 44)
                .background(Color.cardBackground)
                .cornerRadius(CornerRadius.medium)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)

                // Content: search results list OR popular places grid
                if isActivelySearching {
                    searchResultsList
                } else {
                    popularPlacesGrid
                }

                // Continue Button
                VStack {
                    if let place = selectedPlace {
                        Button(action: {
                            coordinator.completePlace(place: place)
                        }) {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryButton()
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.md)
                        .transition(.opacity)
                    } else {
                        Color.clear
                            .frame(height: 60)
                            .padding(.bottom, Spacing.md)
                    }
                }
                .background(Color.appBackground)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: searchText) { oldValue, newValue in
            selectedPlace = nil
            placesService.search(query: newValue)
        }
    }

    // MARK: - Search Results List

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if placesService.searchResults.isEmpty && !placesService.isSearching {
                    // No results state
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.textTertiary)

                        Text("No restaurants found")
                            .font(AppFont.body)
                            .foregroundColor(.textSecondary)

                        Text("Try a different search term")
                            .font(AppFont.caption)
                            .foregroundColor(.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(placesService.searchResults) { place in
                        PlaceResultRow(
                            place: place,
                            isSelected: selectedPlace?.id == place.id
                        ) {
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
            .padding(.top, Spacing.sm)
        }
    }

    // MARK: - Popular Places Grid

    private var popularPlacesGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Popular")
                    .font(AppFont.caption)
                    .foregroundColor(.textTertiary)
                    .textCase(.uppercase)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(popularPlaces) { place in
                        PlaceCard(
                            place: place,
                            isSelected: selectedPlace?.id == place.id
                        ) {
                            if selectedPlace?.id == place.id {
                                selectedPlace = nil
                            } else {
                                selectedPlace = place
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}

// MARK: - Search Result Row

struct PlaceResultRow: View {
    let place: Place
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.textPrimary : Color.cardBackground)
                        .frame(width: 44, height: 44)

                    Image(systemName: isSelected ? "checkmark" : "mappin.circle.fill")
                        .font(.system(size: isSelected ? 16 : 20, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? Color.cardBackground : .textSecondary)
                }

                // Name + Location
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(AppFont.body)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    if let location = place.location {
                        Text(location)
                            .font(AppFont.caption)
                            .foregroundColor(.textTertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.cardBackground : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Place Card Component (for grid)

struct PlaceCard: View {
    let place: Place
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: place.imageURL)
                    .font(.system(size: 40))
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.large)

                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.small)
                            .fill(Color.white)
                            .frame(width: 30, height: 30)

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(8)
                }
            }

            Text(place.name)
                .font(AppFont.bodySmall)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

#Preview {
    PlaceSelectionView(coordinator: CreateImpressionCoordinator())
}
