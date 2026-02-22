//
//  DevSeeder.swift
//  impressionsv1
//
//  Dev-only utility that seeds sample impressions directly into SwiftData.
//  Whole file is compiled out in Release builds via #if DEBUG.
//

#if DEBUG
import SwiftUI
import SwiftData

// MARK: - Seeder

struct DevSeeder {

    /// Inserts 2 sample impressions by other users + 2 from the current user.
    /// Safe to call multiple times — each call adds a fresh batch with new IDs.
    static func seedAll(context: ModelContext, currentUser: AuthorModel?) {
        let pallavi = getOrCreateAuthor(name: "Pallavi M", id: "seed-author-pallavi", context: context)
        let rohan   = getOrCreateAuthor(name: "Rohan D",   id: "seed-author-rohan",   context: context)

        let imp1 = buildImpressionOne(author: pallavi)
        let imp2 = buildImpressionTwo(author: rohan)

        // Self-impressions — only if a current user exists
        var selfImps: [ImpressionModel] = []
        if let me = currentUser {
            selfImps = [
                buildSelfImpressionOne(author: me),
                buildSelfImpressionTwo(author: me)
            ]
        }

        for imp in [imp1, imp2] + selfImps {
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

        // Seed credit counts on self-impressions so recommendation score shows
        selfImps.enumerated().forEach { i, imp in
            imp.creditCount = i == 0 ? 14 : 7
        }

        try? context.save()
        print("🌱 Seeded \(2 + selfImps.count) sample impressions")
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
            createdAt: Date().addingTimeInterval(-86400 * 2),
            title: "Masque is still the best tasting menu in the city, no contest",
            placeName: "Masque, Mahalaxmi",
            companions: "Partner",
            occasion: "Anniversary Dinner",
            priceRange: "₹₹₹₹",
            cardColorRawValue: "blue",
            author: author
        )

        imp.photoWidgets = [
            PhotoDataModel(imageUrl: "sample_photo_1", sortOrder: 0),
            PhotoDataModel(imageUrl: "sample_photo_2", sortOrder: 1),
            PhotoDataModel(imageUrl: "sample_photo_3", sortOrder: 2),
            PhotoDataModel(imageUrl: "sample_photo_4", sortOrder: 3),
        ]

        imp.quoteWidgets = [
            QuoteDataModel(
                prompt: "What did you notice that most people wouldn't?",
                answer: "The kitchen team comes out mid-meal to explain the next course. Not a waiter reading a card — the actual cook.",
                sortOrder: 4
            ),
            QuoteDataModel(
                prompt: "What made you think 'okay, they actually care here'?",
                answer: "They sourced the black garlic from a single farm in Nashik and mentioned it without being asked.",
                sortOrder: 5
            ),
            QuoteDataModel(
                prompt: "How was the pacing?",
                answer: "Immaculate. 11 courses over 3 hours and I never felt rushed or bored.",
                sortOrder: 6
            )
        ]

        imp.infoWidgets = [
            InfoDataModel(title: "What was the vibe?", content: "Intimate, candlelit, very quiet. Not a place for a group chat.", sortOrder: 7),
            InfoDataModel(title: "How much did you spend?", content: "₹8,500 per person with wine pairing", sortOrder: 8)
        ]

        imp.mapWidgets = [
            MapDataModel(
                placeName: "Masque",
                address: "Laxmi Mills, Mahalaxmi, Mumbai",
                latitude: 18.9917,
                longitude: 72.8257,
                sortOrder: 9
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
                sortOrder: 10
            )
        ]

        return imp
    }

    // MARK: - Sample impression 2 — Rohan at Bastian

    private static func buildImpressionTwo(author: AuthorModel) -> ImpressionModel {
        let imp = ImpressionModel(
            createdAt: Date().addingTimeInterval(-3600 * 5),
            title: "Bastian on a weekday lunch is a completely different restaurant",
            placeName: "Bastian, Bandra",
            companions: "Solo",
            occasion: "Lunch",
            priceRange: "₹₹₹",
            cardColorRawValue: "pink",
            author: author
        )

        imp.photoWidgets = [
            PhotoDataModel(imageUrl: "sample_photo_5", sortOrder: 0),
            PhotoDataModel(imageUrl: "sample_photo_6", sortOrder: 1),
            PhotoDataModel(imageUrl: "sample_photo_7", sortOrder: 2),
            PhotoDataModel(imageUrl: "sample_photo_8", sortOrder: 3),
        ]

        imp.quoteWidgets = [
            QuoteDataModel(
                prompt: "Was there anything about the quality of basics that stood out?",
                answer: "The butter garlic prawn has stayed exactly the same for 6 years. That's not laziness, that's conviction.",
                sortOrder: 4
            ),
            QuoteDataModel(
                prompt: "What would a regular know to ask for or avoid?",
                answer: "Sit on the terrace on weekday afternoons. You get the view with none of the Saturday crowd.",
                sortOrder: 5
            )
        ]

        imp.infoWidgets = [
            InfoDataModel(title: "What was the vibe?", content: "Breezy, unhurried. Half the tables were empty — in a good way.", sortOrder: 6),
            InfoDataModel(title: "When did you go?", content: "Tuesday, 1 PM", sortOrder: 7)
        ]

        imp.orderListWidgets = [
            {
                let ol = OrderListDataModel(title: "What did you order?", sortOrder: 8)
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
                sortOrder: 9
            )
        ]

        return imp
    }

    // MARK: - Self impression 1 — The Bombay Canteen

    private static func buildSelfImpressionOne(author: AuthorModel) -> ImpressionModel {
        let imp = ImpressionModel(
            createdAt: Date().addingTimeInterval(-86400 * 4),
            title: "Bombay Canteen still does comfort food better than anyone",
            placeName: "The Bombay Canteen, Lower Parel",
            companions: "Friends",
            occasion: "Sunday Brunch",
            priceRange: "₹₹₹",
            cardColorRawValue: "pink",
            author: author,
            creditCount: 14
        )

        imp.photoWidgets = [
            PhotoDataModel(imageUrl: "sample_photo_1", sortOrder: 0),
            PhotoDataModel(imageUrl: "sample_photo_8", sortOrder: 1),
            PhotoDataModel(imageUrl: "sample_photo_3", sortOrder: 2),
            PhotoDataModel(imageUrl: "sample_photo_5", sortOrder: 3),
        ]

        imp.quoteWidgets = [
            QuoteDataModel(
                prompt: "What's one thing that makes this place different?",
                answer: "Every dish has a backstory. The menu reads like a love letter to Indian ingredients, and the food delivers on that promise.",
                sortOrder: 4
            ),
            QuoteDataModel(
                prompt: "What would you tell a first-timer to order?",
                answer: "The podi ghee roast dosa and whatever seasonal special they have. Don't skip dessert — the Canteen Rasgulla is absurd.",
                sortOrder: 5
            )
        ]

        imp.infoWidgets = [
            InfoDataModel(title: "When did you go?", content: "Sunday, 12:30 PM — peak brunch", sortOrder: 6),
            InfoDataModel(title: "Noise level?", content: "Lively but not too loud. Good for a table of 4–6.", sortOrder: 7)
        ]

        imp.orderListWidgets = [
            {
                let ol = OrderListDataModel(title: "What did you order?", sortOrder: 8)
                ol.allItems = [
                    OrderItemModel(name: "Podi Ghee Roast Dosa",   column: "left"),
                    OrderItemModel(name: "Akuri on Toast",          column: "left"),
                    OrderItemModel(name: "Canteen Rasgulla",        column: "right"),
                    OrderItemModel(name: "Kokum Cooler",            column: "right")
                ]
                return ol
            }()
        ]

        imp.mapWidgets = [
            MapDataModel(
                placeName: "The Bombay Canteen",
                address: "Process House, Lower Parel, Mumbai",
                latitude: 18.9994,
                longitude: 72.8302,
                sortOrder: 9
            )
        ]

        return imp
    }

    // MARK: - Self impression 2 — Cafe Zoe

    private static func buildSelfImpressionTwo(author: AuthorModel) -> ImpressionModel {
        let imp = ImpressionModel(
            createdAt: Date().addingTimeInterval(-86400 * 1),
            title: "Cafe Zoe for solo work mornings — still the gold standard",
            placeName: "Cafe Zoe, Lower Parel",
            companions: "Solo",
            occasion: "Work from Cafe",
            priceRange: "₹₹",
            cardColorRawValue: "blue",
            author: author,
            creditCount: 7
        )

        imp.photoWidgets = [
            PhotoDataModel(imageUrl: "sample_photo_2", sortOrder: 0),
            PhotoDataModel(imageUrl: "sample_photo_6", sortOrder: 1),
            PhotoDataModel(imageUrl: "sample_photo_4", sortOrder: 2),
            PhotoDataModel(imageUrl: "sample_photo_7", sortOrder: 3),
        ]

        imp.quoteWidgets = [
            QuoteDataModel(
                prompt: "What keeps you coming back?",
                answer: "The light, the music, the fact that nobody rushes you. Three hours of deep work and two coffees — that's the formula.",
                sortOrder: 4
            )
        ]

        imp.infoWidgets = [
            InfoDataModel(title: "Best time to go?", content: "9–11 AM on weekdays. Quiet, good seats, fast wifi.", sortOrder: 5),
            InfoDataModel(title: "WiFi?", content: "Yes, fast and reliable. Ask at the counter.", sortOrder: 6)
        ]

        imp.orderListWidgets = [
            {
                let ol = OrderListDataModel(title: "What did you order?", sortOrder: 7)
                ol.allItems = [
                    OrderItemModel(name: "Flat White",                    column: "left"),
                    OrderItemModel(name: "Avocado Toast",                 column: "left"),
                    OrderItemModel(name: "Lemon Tart",                    column: "right"),
                    OrderItemModel(name: "Cold Brew (refill)",            column: "right")
                ]
                return ol
            }()
        ]

        imp.mapWidgets = [
            MapDataModel(
                placeName: "Cafe Zoe",
                address: "Mathew Road, Lower Parel, Mumbai",
                latitude: 18.9981,
                longitude: 72.8267,
                sortOrder: 8
            )
        ]

        return imp
    }
}

// MARK: - Seed Button (shown in feed header, DEBUG only)

struct SeedButton: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserManager.self) private var userManager
    @State private var justSeeded = false

    var body: some View {
        Button {
            DevSeeder.seedAll(context: modelContext, currentUser: userManager.currentUser)
            withAnimation(.spring(duration: 0.3)) { justSeeded = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { justSeeded = false }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: justSeeded ? "checkmark" : "plus.square.dashed")
                    .font(.system(size: 13, weight: .medium))
                    .contentTransition(.symbolEffect(.replace))
                Text(justSeeded ? "Seeded!" : "Seed")
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
