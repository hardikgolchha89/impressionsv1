//
//  impressionsv1App.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 07/02/26.
//

import SwiftUI
import SwiftData

@main
struct impressionsv1App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // Core models
            AuthorModel.self,
            ImpressionModel.self,

            // Widget models
            PhotoDataModel.self,
            QuoteDataModel.self,
            InfoDataModel.self,
            MapDataModel.self,
            FoodGridDataModel.self,
            FoodItemModel.self,
            OrderListDataModel.self,
            OrderItemModel.self,
            PairingDataModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema changed (e.g. new fields added) — wipe the old store and recreate.
            // This is safe during development; add a proper migration plan before shipping.
            print("⚠️ ModelContainer failed (\(error)). Deleting old store and recreating...")
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            // Also remove WAL/SHM sidecar files
            let base = storeURL.deletingPathExtension()
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-wal"))
            try? FileManager.default.removeItem(at: base.appendingPathExtension("sqlite-shm"))
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not recreate ModelContainer after wipe: \(error)")
            }
        }
    }()

    @State private var userManager = UserManager()
    @State private var recommendationStore = RecommendationStore()
    @State private var hotlistStore = HotlistStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(userManager)
                .environment(recommendationStore)
                .environment(hotlistStore)
                .onAppear {
                    userManager.loadExistingUser(context: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Root — decides onboarding vs main feed

struct RootView: View {
    @Environment(UserManager.self) private var userManager

    var body: some View {
        if userManager.isOnboarded {
            ContentView()
        } else {
            OnboardingFlowView {
                // onComplete: SwiftUI will re-evaluate body because isOnboarded changed
            }
        }
    }
}
