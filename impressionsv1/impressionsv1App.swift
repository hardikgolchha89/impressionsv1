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
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var userManager = UserManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(userManager)
                .onAppear {
                    // VERIFICATION LOG - If you see this, new code is running!
                    print("🚀🚀🚀 CODE UPDATED - BUILD TIME: Feb 15, 2026 - COMMIT: be26ce7 🚀🚀🚀")

                    // Load or create user on app launch
                    userManager.loadOrCreateUser(context: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
