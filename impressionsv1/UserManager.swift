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

    init() {}

    // MARK: - Computed

    /// True once the user has finished onboarding
    var isOnboarded: Bool {
        currentUser?.isOnboarded ?? false
    }

    var hasUser: Bool {
        currentUser != nil
    }

    // MARK: - Boot

    /// Call once at app startup. Loads an existing user if one exists.
    /// New users (no record found) will be sent through onboarding.
    func loadExistingUser(context: ModelContext) {
        self.modelContext = context
        let descriptor = FetchDescriptor<AuthorModel>()
        if let users = try? context.fetch(descriptor), let first = users.first {
            currentUser = first
            print("✅ Loaded user: \(first.name), onboarded=\(first.isOnboarded)")
        }
        // No user found → onboarding will create one
    }

    // MARK: - Onboarding

    /// Creates the user record during sign-up (name + phone).
    func createUser(name: String, phoneNumber: String, context: ModelContext) {
        self.modelContext = context
        let user = AuthorModel(name: name, phoneNumber: phoneNumber, isOnboarded: false)
        context.insert(user)
        try? context.save()
        currentUser = user
        print("✅ Created user during onboarding: \(name)")
    }

    /// Marks onboarding complete and saves.
    func completeOnboarding() {
        guard let user = currentUser, let context = modelContext else { return }
        user.isOnboarded = true
        try? context.save()
        print("✅ Onboarding complete for \(user.name)")
    }

    // MARK: - Profile

    func updateProfile(name: String, profileImageUrl: String?) {
        guard let user = currentUser, let context = modelContext else { return }
        user.name = name
        user.profileImageUrl = profileImageUrl
        try? context.save()
    }

    // MARK: - Legacy shim (keeps CreateImpressionCoordinator working)

    func loadOrCreateUser(context: ModelContext) {
        loadExistingUser(context: context)
    }
}
