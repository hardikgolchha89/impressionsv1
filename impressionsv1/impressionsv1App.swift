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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
