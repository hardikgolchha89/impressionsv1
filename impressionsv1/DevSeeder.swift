//
//  DevSeeder.swift
//  impressionsv1
//
//  Dev-only utility that seeds 2 sample impressions by fictional users
//  directly into SwiftData — no create flow needed.
//
//  Whole file is compiled out in Release builds via #if DEBUG.
//

#if DEBUG
import SwiftUI
import SwiftData

// MARK: - Seeder

struct DevSeeder {

    /// Inserts 2 sample impressions by other users into the store.
    /// Safe to call multiple times — each call adds a fresh pair with new IDs.
    static func seedTwo(context: ModelContext) {
        let pallavi = getOrCreateAuthor(name: "Pallavi M", id: "seed-author-pallavi", context: context)
        let rohan   = getOrCreateAuthor(name: "Rohan D",   id: "seed-author-rohan",   context: context)

        let imp1 = buildImpressionOne(author: pallavi)
        let imp2 = buildImpressionTwo(author: rohan)

        for imp in [imp1, imp2] {
            context.insert(imp)
            imp.quoteWidgets?.forEach  { context.insert($0) }
            imp.infoWidgets?.forEach   { context.insert($0) }
            imp.mapWidgets?.forEach    { context.insert($0) }
            imp.foodGridWidgets?.forEach { fg in
                context.insert(fg)
                fg.items?.forEach { context.insert($0) }
            }
            imp.orderListWidgets?.forEach { ol in
                context.insert(ol)
                ol.allItems?.forEach { context.insert($0) }
            }
            imp.photoWidgets?.forEach  { context.insert($0) }
            imp.pairingWidgets?.forEach { context.insert($0) }
        }

        try? context.save()
        print("🌱 Seeded 2 sample impressions")
    }

    // MARK: - Author helper

    private static func getOrCreateAuthor(name: String, id: String, context: ModelContext) -> AuthorModel {
        let desc = FetchDescriptor<AuthorModel>(predicate: #Predicate { $0.id == id })
        if let existing = try? context.fetch(desc).first { return existing }
        let author = AuthorModel(id: id, name: name)
        context.insert(author)
        return author
    }

    // MARK: - Sample impression 1 — Pallavi at Masque

    private static func buildImpressionOne(author: AuthorModel) -> ImpressionModel {
        let imp = ImpressionModel(
            createdAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            title: "Masque is still the best tasting menu in the city, no contest",
            placeName: "Masque, Mahalaxmi",
            companions: "Partner",
            occasion: "Anniversary Dinner",
            priceRange: "₹₹₹₹",
            cardColorRawValue: "blue",
            author: author
        )

        imp.quoteWidgets = [
            QuoteDataModel(
                prompt: "What did you notice that most people wouldn't?",
                answer: "The kitchen team comes out mid-meal to explain the next course. Not a waiter reading a card — the actual cook.",
                sortOrder: 0
            ),
            QuoteDataModel(
                prompt: "What made you think 'okay, they actually care here'?",
                answer: "They sourced the black garlic from a single farm in Nashik and mentioned it without being asked.",
                sortOrder: 1
            ),
            QuoteDataModel(
                prompt: "How was the pacing?",
                answer: "Immaculate. 11 courses over 3 hours and I never felt rushed or bored.",
                sortOrder: 2
            )
        ]

        imp.infoWidgets = [
            InfoDataModel(title: "What was the vibe?", content: "Intimate, candlelit, very quiet. Not a place for a group chat.", sortOrder: 3),
            InfoDataModel(title: "How much did you spend?", content: "₹8,500 per person with wine pairing", sortOrder: 4)
        ]

        imp.mapWidgets = [
            MapDataModel(
                placeName: "Masque",
                address: "Laxmi Mills, Mahalaxmi, Mumbai",
                latitude: 18.9917,
                longitude: 72.8257,
                sortOrder: 5
            )
        ]

        imp.foodGridWidgets = [
            FoodGridDataModel(
                items: [
                    FoodItemModel(name: "Burnt Leek Chawanmushi"),
                    FoodItemModel(name: "Raw Mango Sorbet"),
                    FoodItemModel(name: "Kokum Rasam"),
                    FoodItemModel(name: "Black Garlic Bread"),
                    FoodItemModel(name: "River Fish, Mustard"),
                    FoodItemModel(name: "Goat, Wild Berry Jus")
                ],
                sortOrder: 6
            )
        ]

        return imp
    }

    // MARK: - Sample impression 2 — Rohan at Bastian

    private static func buildImpressionTwo(author: AuthorModel) -> ImpressionModel {
        let imp = ImpressionModel(
            createdAt: Date().addingTimeInterval(-3600 * 5), // 5 hours ago
            title: "Bastian on a weekday lunch is a completely different restaurant",
            placeName: "Bastian, Bandra",
            companions: "Solo",
            occasion: "Lunch",
            priceRange: "₹₹₹",
            cardColorRawValue: "pink",
            author: author
        )

        imp.quoteWidgets = [
            QuoteDataModel(
                prompt: "Was there anything about the quality of basics that stood out?",
                answer: "The butter garlic prawn has stayed exactly the same for 6 years. That's not laziness, that's conviction.",
                sortOrder: 0
            ),
            QuoteDataModel(
                prompt: "What would a regular know to ask for or avoid?",
                answer: "Sit on the terrace on weekday afternoons. You get the view with none of the Saturday crowd.",
                sortOrder: 1
            )
        ]

        imp.infoWidgets = [
            InfoDataModel(title: "What was the vibe?", content: "Breezy, unhurried. Half the tables were empty — in a good way.", sortOrder: 2),
            InfoDataModel(title: "When did you go?", content: "Tuesday, 1 PM", sortOrder: 3)
        ]

        imp.orderListWidgets = [
            {
                let ol = OrderListDataModel(
                    title: "What did you order?",
                    sortOrder: 4
                )
                ol.allItems = [
                    OrderItemModel(name: "Butter Garlic Prawns",  column: "left"),
                    OrderItemModel(name: "Lobster Bisque",        column: "left"),
                    OrderItemModel(name: "Truffle Mac & Cheese",  column: "right"),
                    OrderItemModel(name: "Passion Fruit Tart",    column: "right")
                ]
                return ol
            }()
        ]

        imp.mapWidgets = [
            MapDataModel(
                placeName: "Bastian",
                address: "Linking Road, Bandra West, Mumbai",
                latitude: 19.0596,
                longitude: 72.8295,
                sortOrder: 5
            )
        ]

        return imp
    }
}

// MARK: - Seed Button (shown in feed header, DEBUG only)

struct SeedButton: View {
    @Environment(\.modelContext) private var modelContext
    @State private var justSeeded = false

    var body: some View {
        Button {
            DevSeeder.seedTwo(context: modelContext)
            withAnimation(.spring(duration: 0.3)) { justSeeded = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { justSeeded = false }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: justSeeded ? "checkmark" : "plus.square.dashed")
                    .font(.system(size: 13, weight: .medium))
                    .contentTransition(.symbolEffect(.replace))
                Text(justSeeded ? "Seeded!" : "Seed 2")
                    .font(.custom("HKGrotesk-SemiBold", size: 12))
            }
            .foregroundColor(justSeeded ? .appGreen : .appGrayText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.appGrayText.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}
#endif
