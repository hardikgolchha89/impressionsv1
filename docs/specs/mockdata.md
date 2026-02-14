# MockData.swift - Complete Code

```swift
import Foundation

struct MockData {
    
    // MARK: - Sample Impression 1 (Pink Card)
    static let impression1 = Impression(
        id: "1",
        authorId: "user_hardik",
        authorName: "Hardik G",
        authorAvatar: nil,
        timestamp: Date().addingTimeInterval(-60 * 60 * 24 * 12), // 12 days ago
        
        title: "Life Changing Dinner at The Bombay Canteen after ages",
        placeName: "The Bombay Canteen",
        placeLocation: "Lower Parel",
        companions: "Table for 5",
        occasion: "First Date",
        priceRange: "₹₹₹",
        
        heroImage: nil, // placeholder
        cardColor: .pink,
        
        widgets: [
            // Food Grid
            .foodGrid(items: [
                FoodItem(id: "f1", name: "Plain Podi Ghee Dosa", imageName: nil),
                FoodItem(id: "f2", name: "Scrambled Eggs", imageName: nil),
                FoodItem(id: "f3", name: "Canteen Rasgulla", imageName: nil),
                FoodItem(id: "f4", name: "Butter Sada Dosa", imageName: nil),
                FoodItem(id: "f5", name: "Filter Coffee", imageName: nil),
                FoodItem(id: "f6", name: "Masala Dosa", imageName: nil)
            ]),
            
            // Quote 1
            .quote(data: QuoteData(
                id: "q1",
                prompt: "What did you notice that most people wouldn't?",
                answer: "They were sharing their favourite dishes they like. If you speak to them and not just repeating the menu listings."
            )),
            
            // Quote 2
            .quote(data: QuoteData(
                id: "q2",
                prompt: "What made you think 'okay, they actually care here'?",
                answer: "The staff started giving suggestions as per their liking and not just repeating the menu listings."
            )),
            
            // Order List
            .orderList(
                title: "What did we order for the table?",
                items: [
                    OrderItem(id: "o1", name: "Scramble Egg Quesadillas", variant: nil),
                    OrderItem(id: "o2", name: "Akuri", variant: nil),
                    OrderItem(id: "o3", name: "Strawberry and White Chocolate waffle", variant: nil),
                    OrderItem(id: "o4", name: "spinach & ricotta Ravioli", variant: nil),
                    OrderItem(id: "o5", name: "smoky paprika penne", variant: nil),
                    OrderItem(id: "o6", name: "Akuri", variant: nil),
                    OrderItem(id: "o7", name: "Strawberry Smoothie", variant: nil)
                ]
            ),
            
            // Photo 1
            .photo(data: PhotoData(
                id: "p1",
                imageUrl: nil,
                caption: nil
            )),
            
            // Photo 2
            .photo(data: PhotoData(
                id: "p2",
                imageUrl: nil,
                caption: "The presentation was beautiful"
            )),
            
            // Pairing
            .pairing(data: PairingData(
                id: "pair1",
                placeName: "Bombay Sweet Shop",
                location: "Palladium Mall",
                imageUrl: nil
            )),
            
            // Info 1
            .info(data: InfoData(
                id: "i1",
                title: "What was the vibe?",
                content: "Kanda MH Gandhipuram Dadar 12:31 PM to 12:40 PM",
                icon: nil
            )),
            
            // Info 2
            .info(data: InfoData(
                id: "i2",
                title: "How much did you spend?",
                content: "We were 7 of us (2 adults). Price per person came around 700/-",
                icon: nil
            )),
            
            // Map
            .map(data: MapData(
                id: "m1",
                placeName: "The Bombay Canteen",
                address: "Lower Parel, Mumbai",
                latitude: nil,
                longitude: nil
            ))
        ]
    )
    
    // MARK: - Sample Impression 2 (Blue Card)
    static let impression2 = Impression(
        id: "2",
        authorId: "user_taashi",
        authorName: "Taashi T",
        authorAvatar: nil,
        timestamp: Date().addingTimeInterval(-60 * 60 * 24 * 5), // 5 days ago
        
        title: "Amazing brunch spot in Bandra",
        placeName: "Cafe Zoe",
        placeLocation: "Bandra",
        companions: "Solo",
        occasion: "Weekend Brunch",
        priceRange: "₹₹",
        
        heroImage: nil, // placeholder
        cardColor: .blue,
        
        widgets: [
            // Food Grid
            .foodGrid(items: [
                FoodItem(id: "f7", name: "Avocado Toast", imageName: nil),
                FoodItem(id: "f8", name: "Eggs Benedict", imageName: nil),
                FoodItem(id: "f9", name: "Fresh Orange Juice", imageName: nil),
                FoodItem(id: "f10", name: "Croissant", imageName: nil)
            ]),
            
            // Quote 1
            .quote(data: QuoteData(
                id: "q3",
                prompt: "What made this place special?",
                answer: "Perfect for solo dining. The staff was attentive without being intrusive. Great natural lighting for reading."
            )),
            
            // Photo 1
            .photo(data: PhotoData(
                id: "p3",
                imageUrl: nil,
                caption: "The avocado toast was Instagram-worthy"
            )),
            
            // Info 1
            .info(data: InfoData(
                id: "i3",
                title: "Best time to visit?",
                content: "Weekday mornings around 10 AM. Weekends get crowded after 11.",
                icon: nil
            )),
            
            // Pairing
            .pairing(data: PairingData(
                id: "pair2",
                placeName: "Collin's",
                location: "Malad",
                imageUrl: nil
            )),
            
            // Map
            .map(data: MapData(
                id: "m2",
                placeName: "Cafe Zoe",
                address: "Bandra West, Mumbai",
                latitude: nil,
                longitude: nil
            ))
        ]
    )
    
    // MARK: - Third Impression (Pink Card - for variety)
    static let impression3 = Impression(
        id: "3",
        authorId: "user_hardik",
        authorName: "Hardik G",
        authorAvatar: nil,
        timestamp: Date().addingTimeInterval(-60 * 60 * 24 * 2), // 2 days ago
        
        title: "Quick bite at Porvai after badminton",
        placeName: "Porvai",
        placeLocation: "Borivali",
        companions: "Friends (3 of us)",
        occasion: "Post-workout",
        priceRange: "₹₹",
        
        heroImage: nil, // placeholder
        cardColor: .pink,
        
        widgets: [
            // Order List
            .orderList(
                title: "What did we order?",
                items: [
                    OrderItem(id: "o8", name: "Coconut Rice", variant: nil),
                    OrderItem(id: "o9", name: "Tamarind Rice", variant: nil),
                    OrderItem(id: "o10", name: "Malabar Parotta", variant: nil),
                    OrderItem(id: "o11", name: "Filter Coffee", variant: nil)
                ]
            ),
            
            // Quote 1
            .quote(data: QuoteData(
                id: "q4",
                prompt: "What stood out?",
                answer: "Very homely vibes. The owner shared personal stories about the dishes. Felt like eating at someone's home."
            )),
            
            // Info 1
            .info(data: InfoData(
                id: "i4",
                title: nil,
                content: "Perfect for post-workout meals. Light on the stomach despite being flavorful.",
                icon: nil
            )),
            
            // Map
            .map(data: MapData(
                id: "m3",
                placeName: "Porvai",
                address: "Borivali West, Mumbai",
                latitude: nil,
                longitude: nil
            ))
        ]
    )
    
    // MARK: - All Impressions Array
    static let allImpressions = [impression1, impression2, impression3]
}
```

---

## Review Checklist for MockData.swift

**Impression 1 (Bombay Canteen):**
- ✓ Pink card
- ✓ All widget types represented
- ✓ 9 widgets total
- ✓ Has food grid, 2 quotes, order list, 2 photos, pairing, 2 infos, map
- ✓ Realistic data from your designs

**Impression 2 (Cafe Zoe):**
- ✓ Blue card
- ✓ Simpler/shorter (6 widgets)
- ✓ Shows variety in widget combinations
- ✓ Different author

**Impression 3 (Porvai):**
- ✓ Pink card
- ✓ Even simpler (4 widgets)
- ✓ Shows minimal viable impression
- ✓ Same author as Impression 1

**Questions:**
1. Is the data realistic enough?
2. Need more/fewer sample impressions?
3. Want different widget combinations?

If this looks good, next I'll create update instructions for ContentView, FeedCardView, and DetailView.
