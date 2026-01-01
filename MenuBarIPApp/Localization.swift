//
//  Localization.swift
//  MenuBarIP
//
//  Created on macOS
//

import Combine
import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable {
    case russian = "ru"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .russian:
            return "Русский"
        case .english:
            return "English"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Default to system language
            let systemLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
            self.currentLanguage = systemLanguage == "ru" ? .russian : .english
        }
    }
    
    func localizedString(_ key: LocalizedStringKey) -> String {
        switch currentLanguage {
        case .russian:
            return russianStrings[key] ?? key.rawValue
        case .english:
            return englishStrings[key] ?? key.rawValue
        }
    }
}

struct LocalizedStringKey: Hashable {
    let rawValue: String
    
    static let ipAddress = LocalizedStringKey(rawValue: "IP адрес")
    static let country = LocalizedStringKey(rawValue: "Страна")
    static let refresh = LocalizedStringKey(rawValue: "Обновить")
    static let exit = LocalizedStringKey(rawValue: "Выход")
    static let language = LocalizedStringKey(rawValue: "Язык")
    static let loading = LocalizedStringKey(rawValue: "Loading...")
    static let errorMessage = LocalizedStringKey(rawValue: "Не удалось определить IP адрес. Все API не отвечают или вернули несовместимые данные.")
}

private let russianStrings: [LocalizedStringKey: String] = [
    .ipAddress: "IP адрес:",
    .country: "Страна:",
    .refresh: "Обновить",
    .exit: "Выход",
    .language: "Язык",
    .loading: "Загрузка...",
    .errorMessage: "Не удалось определить IP адрес. Все API не отвечают или вернули несовместимые данные."
]

private let englishStrings: [LocalizedStringKey: String] = [
    .ipAddress: "IP Address:",
    .country: "Country:",
    .refresh: "Refresh",
    .exit: "Quit",
    .language: "Language",
    .loading: "Loading...",
    .errorMessage: "Failed to determine IP address. All APIs are not responding or returned incompatible data."
]

