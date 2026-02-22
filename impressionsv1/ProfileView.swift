//
//  ProfileView.swift
//  impressionsv1
//
//  The current user's own profile page.
//  Shows name, impression count, and the private Recommendation Score.
//  Other users visiting your profile see NONE of this score.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(RecommendationStore.self) private var store
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \ImpressionModel.createdAt, order: .reverse)
    private var impressionModels: [ImpressionModel]

    // Only the current user's impressions
    private var myImpressions: [ImpressionModel] {
        guard let me = userManager.currentUser else { return [] }
        return impressionModels.filter { $0.author?.id == me.id }
    }

    private var totalCredits: Int {
        guard let me = userManager.currentUser else { return 0 }
        return store.totalCreditsReceived(authorId: me.id, context: modelContext)
    }

    private var creditsPerPlace: [(placeName: String, count: Int)] {
        guard let me = userManager.currentUser else { return [] }
        return store.creditsPerPlace(authorId: me.id, context: modelContext)
    }

    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Profile Header
                    VStack(spacing: Spacing.md) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.appPink.opacity(0.4))
                                .frame(width: 80, height: 80)

                            Text(String(userManager.currentUser?.name.prefix(1) ?? "Y").uppercased())
                                .font(.custom("HKGrotesk-SemiBold", size: 32))
                                .foregroundColor(.appDarkText)
                        }

                        Text(userManager.currentUser?.name ?? "You")
                            .font(.custom("HKGrotesk-SemiBold", size: 22))
                            .foregroundColor(.appDarkText)

                        // Impression count — no follower count shown
                        Text("\(myImpressions.count) impression\(myImpressions.count == 1 ? "" : "s")")
                            .font(.custom("HKGrotesk-Light", size: 14))
                            .foregroundColor(.appGrayText)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, Spacing.xl)

                    // MARK: - Recommendation Score (private, only visible to self)
                    if totalCredits > 0 || !myImpressions.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            // Section header
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.appPink)

                                Text("Recommendation Score")
                                    .font(.custom("HKGrotesk-SemiBold", size: 14))
                                    .foregroundColor(.appDarkText)

                                Spacer()

                                // Private badge
                                Text("Only you")
                                    .font(.custom("HKGrotesk-Light", size: 11))
                                    .foregroundColor(.appGrayText)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color.appGrayText.opacity(0.12))
                                    )
                            }

                            // Main stat line
                            if totalCredits == 0 {
                                Text("No one has credited an impression yet — keep sharing!")
                                    .font(.custom("HKGrotesk-Light", size: 14))
                                    .foregroundColor(.appGrayText)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("Sent \(totalCredits) \(totalCredits == 1 ? "person" : "people") somewhere good")
                                    .font(.custom("HKGrotesk-SemiBold", size: 20))
                                    .foregroundColor(.appDarkText)

                                // Per-place breakdown (up to 5 places)
                                if !creditsPerPlace.isEmpty {
                                    VStack(spacing: 6) {
                                        ForEach(creditsPerPlace.prefix(5), id: \.placeName) { entry in
                                            HStack {
                                                Text(entry.placeName)
                                                    .font(.custom("HKGrotesk-Light", size: 13))
                                                    .foregroundColor(.appDarkText)

                                                Spacer()

                                                Text("\(entry.count)")
                                                    .font(.custom("HKGrotesk-SemiBold", size: 13))
                                                    .foregroundColor(.appDarkText)
                                            }
                                            .padding(.vertical, 4)

                                            if entry.placeName != creditsPerPlace.prefix(5).last?.placeName {
                                                Divider()
                                                    .background(Color.appGrayText.opacity(0.2))
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(Spacing.lg)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                    }

                    // MARK: - My Impressions Grid
                    if !myImpressions.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("My Impressions")
                                .font(.custom("HKGrotesk-SemiBold", size: 14))
                                .foregroundColor(.appDarkText)
                                .padding(.horizontal, Spacing.lg)

                            LazyVStack(spacing: Spacing.md) {
                                ForEach(myImpressions) { model in
                                    let impression = model.asStruct
                                    NavigationLink(destination: ImpressionDetailView(impression: ImpressionDetail(from: impression))) {
                                        ProfileImpressionRow(impression: impression)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                        .padding(.bottom, 40)
                    } else {
                        VStack(spacing: Spacing.sm) {
                            Text("No impressions yet")
                                .font(.custom("HKGrotesk-Light", size: 16))
                                .foregroundColor(.appGrayText)
                            Text("Start by creating your first one!")
                                .font(.custom("HKGrotesk-Light", size: 13))
                                .foregroundColor(.appGrayText.opacity(0.7))
                        }
                        .padding(.top, 40)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Profile Impression Row

private struct ProfileImpressionRow: View {
    let impression: Impression

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Color swatch
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(impression.cardColor.color)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text(impression.title)
                    .font(.custom("HKGrotesk-SemiBold", size: 13))
                    .foregroundColor(.appDarkText)
                    .lineLimit(2)

                Text(impression.placeName)
                    .font(.custom("HKGrotesk-Light", size: 12))
                    .foregroundColor(.appGrayText)
            }

            Spacer()

            // Credit count badge (only if > 0)
            if impression.creditCount > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appPink)
                    Text("\(impression.creditCount)")
                        .font(.custom("HKGrotesk-SemiBold", size: 12))
                        .foregroundColor(.appDarkText)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appGrayText.opacity(0.5))
        }
        .padding(Spacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView()
    }
}
