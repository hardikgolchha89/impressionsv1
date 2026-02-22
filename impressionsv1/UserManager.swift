//
//  UserManager.swift
//  impressionsv1
//
//  Manages the current user/author for the app
//

import Foundation
import SwiftUI
import SwiftData

/// Manages the current user and provides access throughout the app
@Observable
class UserManager {
    private(set) var currentUser: AuthorModel?
    private var modelContext: ModelContext?

    init() {
        // Context will be injected after init
    }

    /// Load or create the current user
    /// Call this once during app startup with the model context
    func loadOrCreateUser(context: ModelContext) {
        self.modelContext = context

        // Try to fetch existing user
        let descriptor = FetchDescriptor<AuthorModel>()
        if let existingUsers = try? context.fetch(descriptor),
           let firstUser = existingUsers.first {
            currentUser = firstUser
            print("✅ Loaded existing user: \(firstUser.name)")
        } else {
            // Create default user
            let newUser = AuthorModel(
                name: "You",
                profileImageUrl: nil
            )
            context.insert(newUser)
            try? context.save()
            currentUser = newUser
            print("✅ Created new user: \(newUser.name)")
        }
    }

    /// Update the user's profile
    func updateProfile(name: String, profileImageUrl: String?) {
        guard let user = currentUser, let context = modelContext else { return }

        user.name = name
        user.profileImageUrl = profileImageUrl

        try? context.save()
        print("✅ Updated user profile: \(name)")
    }

    /// Check if user is loaded
    var hasUser: Bool {
        currentUser != nil
    }
}
