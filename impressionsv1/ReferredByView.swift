//
//  ReferredByView.swift
//  impressionsv1
//
//  Optional "Referred By" step in the create flow.
//  Soft prompt: "Did someone's impression here convince you to visit?"
//  Shows a scrollable strip of existing impressions for this place.
//  Completely optional — prominent Skip button.
//

import SwiftUI
import SwiftData

struct ReferredByView: View {
    @ObservedObject var coordinator: CreateImpressionCoordinator
    @Environment(RecommendationStore.self) private var store
    @Environment(UserManager.self) private var userManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ImpressionModel.createdAt, order: .reverse)
    private var allImpressions: [ImpressionModel]

    /// Impressions for this place, by other users
    private var placeImpressions: [Impression] {
        guard let place = coordinator.data.place else { return [] }
        let me = userManager.currentUser?.id ?? ""
        return allImpressions
            .filter { model in
                model.placeName.lowercased().contains(place.name.lowercased()) &&
                model.author?.id != me
            }
            .map { $0.asStruct }
    }

    @State private var selectedImpressionId: String? = nil

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { coordinator.goBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Credit an Impression")
                        .font(AppFont.title2)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    // Skip button (prominent)
                    Button(action: { coordinator.completeReferredBy(referredImpressionId: nil) }) {
                        Text("Skip")
                            .font(.custom("HKGrotesk-SemiBold", size: 15))
                            .foregroundColor(.textSecondary)
                            .frame(width: 56, height: 44)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Prompt text
                        VStack(spacing: Spacing.sm) {
                            Text("Did someone's impression here convince you to visit?")
                                .font(.custom("HKGrotesk-SemiBold", size: 20))
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)

                            Text("Credit their impression. Completely optional.")
                                .font(.custom("HKGrotesk-Light", size: 14))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.xl)

                        if placeImpressions.isEmpty {
                            // No other impressions for this place
                            VStack(spacing: Spacing.sm) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundColor(.textTertiary)

                                Text("No other impressions for \(coordinator.data.place?.name ?? "this place") yet.")
                                    .font(.custom("HKGrotesk-Light", size: 14))
                                    .foregroundColor(.textTertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                        } else {
                            // Horizontal strip of impression cards to credit
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Impressions for \(coordinator.data.place?.name ?? "")")
                                    .font(.custom("HKGrotesk-Light", size: 12))
                                    .foregroundColor(.textTertiary)
                                    .padding(.horizontal, Spacing.md)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: Spacing.md) {
                                        ForEach(placeImpressions) { impression in
                                            ReferredByCard(
                                                impression: impression,
                                                isSelected: selectedImpressionId == impression.id
                                            ) {
                                                withAnimation(.spring(duration: 0.2)) {
                                                    if selectedImpressionId == impression.id {
                                                        selectedImpressionId = nil
                                                    } else {
                                                        selectedImpressionId = impression.id
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, Spacing.md)
                                }
                            }
                        }

                        // Selected confirmation
                        if let selected = placeImpressions.first(where: { $0.id == selectedImpressionId }) {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.appPink)
                                Text("You'll credit \(selected.author.name)'s impression of \(selected.placeName)")
                                    .font(.custom("HKGrotesk-Light", size: 13))
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.horizontal, Spacing.lg)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                }

                // MARK: - Continue Button
                VStack {
                    Button(action: {
                        coordinator.completeReferredBy(referredImpressionId: selectedImpressionId)
                    }) {
                        Text(selectedImpressionId != nil ? "Credit & Continue" : "Continue Without Crediting")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton()
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)
                }
                .background(Color.appBackground)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Referred By Card

private struct ReferredByCard: View {
    let impression: Impression
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Author avatar + name
            HStack(spacing: Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 28, height: 28)
                    Text(String(impression.author.name.prefix(1)).uppercased())
                        .font(.custom("HKGrotesk-SemiBold", size: 12))
                        .foregroundColor(.white)
                }
                Text(impression.author.name)
                    .font(.custom("HKGrotesk-SemiBold", size: 12))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            // Impression title
            Text(impression.title)
                .font(.custom("HKGrotesk-Light", size: 11))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Timestamp
            Text(impression.timeAgo)
                .font(.custom("HKGrotesk-Light", size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(width: 160, height: 140)
        .padding(Spacing.md)
        .background(impression.cardColor.color.opacity(isSelected ? 1.0 : 0.7))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview
#Preview {
    ReferredByView(coordinator: CreateImpressionCoordinator())
}
