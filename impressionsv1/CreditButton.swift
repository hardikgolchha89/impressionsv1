//
//  CreditButton.swift
//  impressionsv1
//
//  The "This sent me" credit button.
//  One tap = give credit. Tap again = undo.
//  Cannot credit your own impression.
//

import SwiftUI
import SwiftData

// MARK: - Credit Button

struct CreditButton: View {
    let impressionId: String
    let impressionTitle: String
    let placeName: String
    let authorId: String
    /// Pass `style: .compact` for feed cards, `.full` for detail page
    var style: Style = .compact

    @Environment(RecommendationStore.self) private var store
    @Environment(UserManager.self) private var userManager
    @Environment(\.modelContext) private var modelContext

    enum Style { case compact, full }

    private var isOwn: Bool {
        userManager.currentUser?.id == authorId
    }

    private var isCredited: Bool {
        store.isCredited(impressionId)
    }

    var body: some View {
        // Hide entirely if this is the user's own impression
        if !isOwn {
            Button(action: toggleCredit) {
                switch style {
                case .compact:
                    Image(systemName: isCredited ? "arrow.up.circle.fill" : "arrow.up.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(isCredited ? Color.appPink : Color.appDarkText)
                        .frame(width: 44, height: 44)
                        .contentTransition(.symbolEffect(.replace))

                case .full:
                    HStack(spacing: 6) {
                        Image(systemName: isCredited ? "arrow.up.circle.fill" : "arrow.up.circle")
                            .font(.system(size: 20))
                            .contentTransition(.symbolEffect(.replace))

                        Text(isCredited ? "Sent me!" : "This sent me")
                            .font(.custom("HKGrotesk-SemiBold", size: 13))
                    }
                    .foregroundStyle(isCredited ? Color.appPink : Color.appDarkText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isCredited
                                  ? Color.appPink.opacity(0.12)
                                  : Color.appDarkText.opacity(0.07))
                    )
                }
            }
            .buttonStyle(.plain)
            .animation(.spring(duration: 0.25), value: isCredited)
        }
    }

    private func toggleCredit() {
        store.toggleCredit(
            for: impressionId,
            impressionTitle: impressionTitle,
            placeName: placeName,
            authorId: authorId,
            currentUserId: userManager.currentUser?.id ?? "",
            context: modelContext,
            creditorName: nil  // anonymous in current single-user build
        )
    }
}
