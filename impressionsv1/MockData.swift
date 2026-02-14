//
//  MockData.swift
//  impressionsv1
//
//  Created by Hardik Golchha on 12/02/26.
//

import Foundation

// MARK: - Mock Authors
struct MockAuthors {
    static let hardik = Author(name: "Hardik G")
    static let taashi = Author(name: "Taashi T")
    static let priya = Author(name: "Priya S")
}

// MARK: - Mock Data
struct MockData {
    static let allImpressions: [Impression] = [
        // Impression 1: Bombay Canteen - Pink
        Impression(
            author: MockAuthors.hardik,
            timeAgo: "12d ago",
            title: "Life Changing Dinner at The Bombay Canteen after ages",
            placeName: "The Bombay Canteen, Lower Parel",
            companions: "Table for 5",
            occasion: "First Date",
            priceRange: "₹₹₹",
            cardColor: .pink,
            previewWidgets: [
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: nil))),
                Widget(type: .quote(QuoteData(
                    prompt: "What did you notice that most people wouldn't?",
                    answer: "They were sharing dishes they like. If you speak to them and not just repeating the menu listings."
                )))
            ],
            allWidgets: [
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: nil))),
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: "The presentation was beautiful"))),
                Widget(type: .quote(QuoteData(
                    prompt: "What did you notice that most people wouldn't?",
                    answer: "They were sharing dishes they like. If you speak to them and not just repeating the menu listings."
                ))),
                Widget(type: .quote(QuoteData(
                    prompt: "What made you think 'okay, they actually care here'?",
                    answer: "The staff actually knew the dishes and could explain them properly."
                ))),
                Widget(type: .info(InfoData(
                    title: "What was the vibe?",
                    content: "Kanda MH Gandhipuram Dadar 12:31 PM to 12:40 PM"
                ))),
                Widget(type: .info(InfoData(
                    title: "How much did you spend?",
                    content: "We were 7 of us (2 adults). Price per person came around 700/-"
                ))),
                Widget(type: .map(MapData(
                    placeName: "The Bombay Canteen",
                    address: "Lower Parel, Mumbai",
                    latitude: nil,
                    longitude: nil
                )))
            ]
        ),
        
        // Impression 2: Cafe Zoe - Blue
        Impression(
            author: MockAuthors.taashi,
            timeAgo: "5d ago",
            title: "Amazing brunch spot in Bandra",
            placeName: "Cafe Zoe, Bandra",
            companions: "Solo",
            occasion: "Weekend Brunch",
            priceRange: "₹₹",
            cardColor: .blue,
            previewWidgets: [
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: "Avocado toast perfection"))),
                Widget(type: .info(InfoData(
                    title: "What was the vibe?",
                    content: "Relaxed Sunday morning atmosphere with great music"
                )))
            ],
            allWidgets: [
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: "Avocado toast perfection"))),
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: nil))),
                Widget(type: .info(InfoData(
                    title: "What was the vibe?",
                    content: "Relaxed Sunday morning atmosphere with great music"
                ))),
                Widget(type: .quote(QuoteData(
                    prompt: "Was there anything about the quality of basics that stood out?",
                    answer: "The coffee was exceptional. They really know their beans."
                ))),
                Widget(type: .orderList(OrderListData(
                    title: "What did you order?",
                    leftColumnItems: [
                        OrderItem(id: "1", name: "Avocado Toast"),
                        OrderItem(id: "2", name: "Flat White")
                    ],
                    rightColumnItems: [
                        OrderItem(id: "3", name: "Berry Smoothie Bowl")
                    ]
                ))),
                Widget(type: .map(MapData(
                    placeName: "Cafe Zoe",
                    address: "Bandra West, Mumbai",
                    latitude: nil,
                    longitude: nil
                )))
            ]
        ),
        
        // Impression 3: O Pedro - Pink
        Impression(
            author: MockAuthors.priya,
            timeAgo: "3d ago",
            title: "Goan food done right at O Pedro",
            placeName: "O Pedro, BKC",
            companions: "Table for 4",
            occasion: "Dinner with Friends",
            priceRange: "₹₹₹",
            cardColor: .pink,
            previewWidgets: [
                Widget(type: .quote(QuoteData(
                    prompt: "Did they do anything technical really well or really poorly?",
                    answer: "The seafood was perfectly cooked. Not overcooked like most places."
                ))),
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: nil)))
            ],
            allWidgets: [
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: nil))),
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: "Prawn Balchao"))),
                Widget(type: .quote(QuoteData(
                    prompt: "Did they do anything technical really well or really poorly?",
                    answer: "The seafood was perfectly cooked. Not overcooked like most places."
                ))),
                Widget(type: .quote(QuoteData(
                    prompt: "How was the pacing?",
                    answer: "Perfect. They gave us time between courses without making us wait too long."
                ))),
                Widget(type: .foodGrid(FoodGridData(items: [
                    FoodItem(id: "1", name: "Prawn Balchao"),
                    FoodItem(id: "2", name: "Pork Vindaloo"),
                    FoodItem(id: "3", name: "Fish Curry"),
                    FoodItem(id: "4", name: "Bebinca")
                ]))),
                Widget(type: .info(InfoData(
                    title: "How much did you spend?",
                    content: "Around ₹2500 per person with drinks"
                )))
            ]
        ),
        
        // Impression 4: Theobroma - Blue
        Impression(
            author: MockAuthors.hardik,
            timeAgo: "1d ago",
            title: "Quick dessert fix at Theobroma",
            placeName: "Theobroma, Colaba",
            companions: "With Partner",
            occasion: "Dessert Date",
            priceRange: "₹",
            cardColor: .blue,
            previewWidgets: [
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: "Chocolate Overload Cake"))),
                Widget(type: .quote(QuoteData(
                    prompt: "What would a regular at this place know to ask for or avoid?",
                    answer: "Get there early evening. The best cakes sell out by 8 PM."
                )))
            ],
            allWidgets: [
                Widget(type: .photo(PhotoData(imageUrl: nil, caption: "Chocolate Overload Cake"))),
                Widget(type: .quote(QuoteData(
                    prompt: "What would a regular at this place know to ask for or avoid?",
                    answer: "Get there early evening. The best cakes sell out by 8 PM."
                ))),
                Widget(type: .orderList(OrderListData(
                    title: "What did you order?",
                    leftColumnItems: [
                        OrderItem(id: "1", name: "Chocolate Overload"),
                        OrderItem(id: "2", name: "Red Velvet Pastry")
                    ],
                    rightColumnItems: [
                        OrderItem(id: "3", name: "Iced Americano")
                    ]
                ))),
                Widget(type: .info(InfoData(
                    content: "The seating is limited, so takeaway is usually faster"
                )))
            ]
        )
    ]
}

