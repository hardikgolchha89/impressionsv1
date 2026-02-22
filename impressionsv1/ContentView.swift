//
//  ContentView.swift
//  impressionsv1
//
//  Main feed screen — redesigned to match feed_and_impressions design files.
//

import SwiftUI
import SwiftData

// MARK: - Tab enum

enum FeedTab: String, CaseIterable {
    case all = "All"
    case friends = "Friends"
    case saved = "Saved"
    case nearby = "Nearby"
}

// MARK: - ContentView

struct ContentView: View {
    @State private var showCreateFlow = false
    @State private var selectedTab: FeedTab = .all
    @State private var recScoreExpanded = false
    @State private var activeNavTab: NavTab = .feed

    @Query(sort: \ImpressionModel.createdAt, order: .reverse) var impressionModels: [ImpressionModel]
    @Environment(UserManager.self) private var userManager
    @Environment(RecommendationStore.self) private var store
    @Environment(\.modelContext) private var modelContext

    private var impressions: [Impression] {
        impressionModels.map { $0.asStruct }
    }

    private var totalCredits: Int {
        guard let me = userManager.currentUser else { return 0 }
        return store.totalCreditsReceived(authorId: me.id, context: modelContext)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.appCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        feedHeader
                        feedTabs
                        recScoreBanner
                        filterStrip
                        feedCards
                        caughtUpFooter
                    }
                    .padding(.bottom, 100) // space for nav bar
                }

                // Bottom navigation
                bottomNav

                // Credit notification banner
                if let note = store.pendingNotification {
                    VStack {
                        CreditNotificationBanner(message: note.message) {
                            store.pendingNotification = nil
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(100)
                        Spacer()
                    }
                    .ignoresSafeArea(edges: .top)
                }
            }
            .animation(.spring(duration: 0.35), value: store.pendingNotification?.id)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCreateFlow) {
                CreateImpressionFlowView()
            }
        }
    }

    // MARK: - Feed Header

    private var feedHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("IMPRESSIONS")
                    .font(.custom("HKGrotesk-SemiBold", size: 11))
                    .foregroundColor(.appOlive)
                    .kerning(1.2)

                Text("Your Feed")
                    .font(.custom("HKGrotesk-Bold", size: 28))
                    .foregroundColor(.appBrown)
            }

            Spacer()

            HStack(spacing: 12) {
                Button { } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appBrown)
                        .frame(width: 36, height: 36)
                        .background(Color.appOffWhite)
                        .clipShape(Circle())
                }

                Button { showCreateFlow = true } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("New")
                            .font(.custom("HKGrotesk-SemiBold", size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.appCrimson)
                    .clipShape(Capsule())
                }

                #if DEBUG
                SeedButton()
                #endif
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Feed Tabs

    private var feedTabs: some View {
        HStack(spacing: 6) {
            ForEach(FeedTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(duration: 0.2)) { selectedTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(.custom(selectedTab == tab ? "HKGrotesk-SemiBold" : "HKGrotesk-Regular", size: 14))
                        .foregroundColor(selectedTab == tab ? .white : .appBrown)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(selectedTab == tab ? Color.appBrown : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    // MARK: - Recommendation Score Banner

    private var recScoreBanner: some View {
        VStack(spacing: 0) {
            // Collapsed row
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    recScoreExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Icon — crimson bullseye on white circle (matches design)
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 38, height: 38)
                        Image(systemName: "target")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appCrimson)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Your Recommendation Score · Private")
                            .font(.custom("HKGrotesk-Regular", size: 11))
                            .foregroundColor(.white.opacity(0.8))

                        HStack(spacing: 5) {
                            Text("\(totalCredits)")
                                .font(.custom("HKGrotesk-Bold", size: 26))
                                .foregroundColor(.white)
                            Text("people took your recs")
                                .font(.custom("HKGrotesk-Regular", size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }

                    Spacer()

                    // Chevron only shown, direction toggles on expand
                    Image(systemName: recScoreExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // Expanded content
            if recScoreExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 1)

                    Text("Every time someone taps \"Took it\" on one of your impressions, your score goes up by 1. It's purely personal — a quiet signal that your taste is actually helping people.")
                        .font(.custom("HKGrotesk-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(3)

                    HStack(spacing: 0) {
                        RecStatCell(value: "\(impressionModels.filter { $0.author?.id == userManager.currentUser?.id }.count)", label: "Impressions posted")
                        RecStatCell(value: "\(totalCredits)", label: "Total takes")
                        RecStatCell(value: "+\(thisWeekCredits)", label: "This week")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "2E8B6E")) // teal green from design
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var thisWeekCredits: Int {
        // Placeholder — in production this would filter by createdAt within 7 days
        return max(0, totalCredits > 0 ? 2 : 0)
    }

    // MARK: - Filter Strip

    private var filterStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(Color.appBrown.opacity(0.2))
                    .frame(width: 3, height: 12)
                    .cornerRadius(2)
                Text("LATEST IMPRESSIONS")
                    .font(.custom("HKGrotesk-SemiBold", size: 10))
                    .foregroundColor(.appBrown.opacity(0.5))
                    .kerning(1.0)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Special category filter cards (square style like design)
                    FilterCard(label: "By Cuisine", subtitle: "Browse types", icon: "fork.knife", iconBg: Color.appOlive)
                    FilterCard(label: "By Location", subtitle: "Browse areas", icon: "mappin.circle.fill", iconBg: Color.appCrimson)

                    // Separator
                    Rectangle()
                        .fill(Color.appGreige)
                        .frame(width: 1, height: 44)
                        .padding(.horizontal, 2)

                    // Place chips from feed — emoji + name
                    let placeNames = Array(Set(impressions.map(\.placeName))).sorted()
                    ForEach(placeNames, id: \.self) { name in
                        PlaceFilterChip(name: name)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Feed Cards

    private var feedCards: some View {
        LazyVStack(spacing: 16) {
            if impressions.isEmpty {
                emptyState
            } else {
                ForEach(impressions) { impression in
                    FeedCardView(impression: impression)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("No impressions yet")
                .font(.custom("HKGrotesk-SemiBold", size: 18))
                .foregroundColor(.appBrown)

            Text("Be the first to share where you ate!")
                .font(.custom("HKGrotesk-Regular", size: 14))
                .foregroundColor(.appBrown.opacity(0.6))

            Button { showCreateFlow = true } label: {
                Text("Post your first impression")
                    .font(.custom("HKGrotesk-SemiBold", size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.appCrimson)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Caught Up Footer

    private var caughtUpFooter: some View {
        VStack(spacing: 6) {
            Text("You're all caught up 🎉")
                .font(.custom("HKGrotesk-Regular", size: 14))
                .foregroundColor(.appBrown.opacity(0.6))
            Text("Post a new impression to keep the feed alive")
                .font(.custom("HKGrotesk-Regular", size: 12))
                .foregroundColor(.appBrown.opacity(0.4))
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
        .opacity(impressions.isEmpty ? 0 : 1)
    }

    // MARK: - Bottom Navigation

    private var bottomNav: some View {
        HStack(spacing: 0) {
            NavButton(tab: .feed, activeTab: $activeNavTab)
            NavButton(tab: .explore, activeTab: $activeNavTab)

            // Center Post button
            Button { showCreateFlow = true } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.appCrimson)
                        .frame(width: 56, height: 56)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            NavButton(tab: .score, activeTab: $activeNavTab)
            NavButton(tab: .profile, activeTab: $activeNavTab)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .padding(.bottom, 4)
        .background(
            Color.appOffWhite
                .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Nav Tab

enum NavTab: String {
    case feed = "Feed"
    case explore = "Explore"
    case post = "Post"
    case score = "Score"
    case profile = "Profile"

    var icon: String {
        switch self {
        case .feed: return "house.fill"
        case .explore: return "magnifyingglass"
        case .post: return "plus"
        case .score: return "target"
        case .profile: return "person.fill"
        }
    }
}

private struct NavButton: View {
    let tab: NavTab
    @Binding var activeTab: NavTab
    @Environment(UserManager.self) private var userManager
    @State private var showProfile = false

    var body: some View {
        Button {
            if tab == .profile { showProfile = true }
            else { activeTab = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: activeTab == tab ? .bold : .regular))
                    .foregroundColor(activeTab == tab ? .appBrown : .appBrown.opacity(0.45))
                Text(tab.rawValue)
                    .font(.custom(activeTab == tab ? "HKGrotesk-SemiBold" : "HKGrotesk-Regular", size: 10))
                    .foregroundColor(activeTab == tab ? .appBrown : .appBrown.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showProfile) {
            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showProfile = false }
                                .foregroundColor(.appBrown)
                        }
                    }
            }
        }
    }
}

// MARK: - Rec Score Stat Cell

private struct RecStatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom("HKGrotesk-Bold", size: 20))
                .foregroundColor(.white)
            Text(label)
                .font(.custom("HKGrotesk-Regular", size: 10))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Filter Card (By Cuisine / By Location style)

private struct FilterCard: View {
    let label: String
    let subtitle: String
    let icon: String
    let iconBg: Color
    @State private var isSelected = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.2)) { isSelected.toggle() }
        } label: {
            HStack(spacing: 10) {
                // Icon square
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.25) : iconBg.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? .white : iconBg)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.custom("HKGrotesk-SemiBold", size: 13))
                        .foregroundColor(isSelected ? .white : .appBrown)
                    Text(subtitle)
                        .font(.custom("HKGrotesk-Regular", size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.75) : .appBrown.opacity(0.45))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.appBrown : Color.appOffWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.clear : Color.appGreige, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Place Filter Chip (individual restaurant)

private struct PlaceFilterChip: View {
    let name: String
    @State private var isSelected = false

    // Pick a consistent emoji per place name (deterministic)
    private var emoji: String {
        let emojis = ["🍽️", "🥘", "🍜", "🍱", "🥗", "🍛", "🫕", "🍲"]
        let idx = abs(name.hashValue) % emojis.count
        return emojis[idx]
    }

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.2)) { isSelected.toggle() }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? Color.appBrown : Color.appOffWhite)
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? Color.clear : Color.appGreige, lineWidth: 1)
                        )
                    Text(emoji)
                        .font(.system(size: 20))
                }
                Text(name.components(separatedBy: " ").prefix(2).joined(separator: " "))
                    .font(.custom("HKGrotesk-Regular", size: 9))
                    .foregroundColor(isSelected ? .appBrown : .appBrown.opacity(0.6))
                    .lineLimit(1)
                    .frame(width: 52)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
    }
}
