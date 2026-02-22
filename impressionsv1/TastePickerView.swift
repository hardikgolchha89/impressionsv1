//
//  TastePickerView.swift
//  impressionsv1
//
//  Onboarding Step 4: Pick 5 favourite restaurants + 5 vibes
//

import SwiftUI

private let mumbaiRestaurants: [String] = [
    "The Bombay Canteen", "Bastian", "Bademiya",
    "Trishna", "Mahesh Lunch Home", "Social Worli",
    "The Table", "Burma Burma", "Masque",
    "Pali Village Cafe", "Cafe Mondegar", "Leopold Cafe",
    "Cafe Noorani", "Olympia Coffee House", "Sarvi",
    "Hakkasan", "Aurus", "Estella", "Bayroute",
    "Papa Pancho"
]

private let vibes: [String] = [
    "staff that glides around the table making you smile",
    "servers who give you a dessert on the house",
    "the kind of place that feels lived-in and loved",
    "tables close enough to eavesdrop on a love story",
    "lighting so perfect every dish looks like art",
    "a menu that changes with the season",
    "the chef actually comes out to chat",
    "regulars who greet each other across the room",
    "somewhere you'd bring someone you're trying to impress",
    "a place that earns its Michelin star quietly"
]

private let required = 5

struct TastePickerView: View {
    @Bindable var coordinator: OnboardingCoordinator
    @State private var activeTab: Tab = .restaurants

    enum Tab { case restaurants, vibes }

    private var totalSelected: Int {
        coordinator.selectedRestaurants.count + coordinator.selectedVibes.count
    }
    private var canContinue: Bool {
        coordinator.selectedRestaurants.count >= required &&
        coordinator.selectedVibes.count >= required
    }

    private var restaurantsLeft: Int { max(0, required - coordinator.selectedRestaurants.count) }
    private var vibesLeft: Int { max(0, required - coordinator.selectedVibes.count) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("Your taste in Mumbai")
                        .font(.custom("HKGrotesk-Bold", size: 26))
                        .foregroundColor(.appCrimson)
                    Text("🍱")
                        .font(.system(size: 22))
                }
                Text("Pick your 5 favourite spots and 5 vibes that speak to you.")
                    .font(.custom("HKGrotesk-Regular", size: 14))
                    .foregroundColor(.appBrown.opacity(0.7))

                // Hint: first pick drives the guide step
                HStack(spacing: 5) {
                    Text("★")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.appCrimson)
                    Text("Your first pick becomes your guide restaurant in the next step")
                        .font(.custom("HKGrotesk-Regular", size: 12))
                        .foregroundColor(.appBrown.opacity(0.55))
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)

            // ── Tab switcher ──────────────────────────────────────────
            HStack(spacing: 0) {
                TabButton(
                    label: "Restaurants \(coordinator.selectedRestaurants.count)/\(required)",
                    isActive: activeTab == .restaurants
                ) { withAnimation(.spring(duration: 0.25)) { activeTab = .restaurants } }

                TabButton(
                    label: "Vibes \(coordinator.selectedVibes.count)/\(required)",
                    isActive: activeTab == .vibes
                ) { withAnimation(.spring(duration: 0.25)) { activeTab = .vibes } }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // ── "N more to pick" counter ──────────────────────────────
            HStack {
                Spacer()
                let left = activeTab == .restaurants ? restaurantsLeft : vibesLeft
                if left > 0 {
                    Text("\(left) more to pick")
                        .font(.custom("HKGrotesk-Regular", size: 12))
                        .foregroundColor(.appBrown.opacity(0.5))
                } else {
                    Text("✓ done")
                        .font(.custom("HKGrotesk-SemiBold", size: 12))
                        .foregroundColor(.appOlive)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            // ── Content ───────────────────────────────────────────────
            ScrollView {
                if activeTab == .restaurants {
                    // Flow layout of pill chips
                    FlowLayout(spacing: 8) {
                        ForEach(mumbaiRestaurants, id: \.self) { name in
                            RestaurantChip(
                                name: name,
                                isSelected: coordinator.selectedRestaurants.contains(name),
                                isFirstPick: coordinator.restaurantPickOrder.first == name
                            ) {
                                toggleRestaurant(name)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                } else {
                    // Checkbox-style vibe list
                    VStack(spacing: 0) {
                        ForEach(vibes, id: \.self) { vibe in
                            VibeRow(
                                text: vibe,
                                isSelected: coordinator.selectedVibes.contains(vibe)
                            ) {
                                toggleVibe(vibe)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: activeTab)

            // ── Bottom CTA ────────────────────────────────────────────
            VStack(spacing: 6) {
                if !canContinue {
                    Text("Pick 5 restaurants + 5 vibes to continue")
                        .font(.custom("HKGrotesk-Regular", size: 12))
                        .foregroundColor(.appBrown.opacity(0.5))
                }

                Button {
                    guard canContinue else { return }
                    coordinator.advance()
                } label: {
                    Text("\(totalSelected) / 10 selected")
                }
                .if(canContinue) { $0.primaryButton() }
                .if(!canContinue) { $0.inactiveButton() }
                .disabled(!canContinue)
                .animation(.easeInOut(duration: 0.2), value: canContinue)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private func toggleRestaurant(_ name: String) {
        withAnimation(.spring(duration: 0.2)) {
            if coordinator.selectedRestaurants.contains(name) {
                coordinator.selectedRestaurants.remove(name)
                coordinator.restaurantPickOrder.removeAll { $0 == name }
            } else if coordinator.selectedRestaurants.count < required {
                coordinator.selectedRestaurants.insert(name)
                coordinator.restaurantPickOrder.append(name)
            }
        }
    }

    private func toggleVibe(_ vibe: String) {
        withAnimation(.spring(duration: 0.2)) {
            if coordinator.selectedVibes.contains(vibe) {
                coordinator.selectedVibes.remove(vibe)
            } else if coordinator.selectedVibes.count < required {
                coordinator.selectedVibes.insert(vibe)
            }
        }
    }
}

// MARK: - Tab button

private struct TabButton: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.custom(isActive ? "HKGrotesk-SemiBold" : "HKGrotesk-Regular", size: 14))
                .foregroundColor(isActive ? .appBrown : .appBrown.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isActive ? Color.appOffWhite : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Restaurant pill chip

private struct RestaurantChip: View {
    let name: String
    let isSelected: Bool
    var isFirstPick: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                if isFirstPick {
                    Text("★")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                Text(name)
                    .font(.custom(isSelected ? "HKGrotesk-SemiBold" : "HKGrotesk-Regular", size: 14))
                    .foregroundColor(isSelected ? .white : .appBrown)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isFirstPick ? Color.appCrimson : (isSelected ? Color.appOlive : Color.appOffWhite))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.appGreige, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Vibe checkbox row

private struct VibeRow: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(isSelected ? Color.appOlive : Color.appOffWhite)
                        .frame(width: 22, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .stroke(isSelected ? Color.appOlive : Color.appGreige, lineWidth: 1)
                        )
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text(text)
                    .font(.custom("HKGrotesk-Regular", size: 14))
                    .foregroundColor(.appBrown)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.appOffWhite)
            )
            .padding(.bottom, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Simple flow layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                y += lineHeight + spacing
                x = 0
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxX = max(maxX, x)
        }
        return CGSize(width: maxX, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += lineHeight + spacing
                x = bounds.minX
                lineHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
