//
//  HotlistStore.swift
//  impressionsv1
//
//  Persists the user's saved ("hotlist") impression IDs using UserDefaults.
//  Injected as an @Environment throughout the app.
//

import SwiftUI

@Observable
final class HotlistStore {
    private(set) var savedIds: Set<String>

    private let key = "hotlist.savedIds"

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: "hotlist.savedIds") ?? []
        self.savedIds = Set(stored)
    }

    func toggle(_ impressionId: String) {
        if savedIds.contains(impressionId) {
            savedIds.remove(impressionId)
        } else {
            savedIds.insert(impressionId)
        }
        persist()
    }

    func isSaved(_ impressionId: String) -> Bool {
        savedIds.contains(impressionId)
    }

    private func persist() {
        UserDefaults.standard.set(Array(savedIds), forKey: key)
    }
}
