//
//  LocalizationService.swift
//  Goglobal School
//
//  Created by Luon Sokphea on 22/11/22.
//

import Foundation

enum Language: String {
    case russian = "ru"
    case english_us = "en"
    case spanish = "es"
}

class LocalizationService {
    
    static let shared = LocalizationService()
    static let changedLanguage = Notification.Name("changedLanguage")
    
    private init() {}
    
    var language: Language {
        get {
            guard let languageString = UserDefaults.standard.string(forKey: "language") else {
                return .english_us
            }
            return Language(rawValue: languageString) ?? .english_us
        } set {
            if newValue != language {
                UserDefaults.standard.setValue(newValue.rawValue, forKey: "language")
                NotificationCenter.default.post(name: LocalizationService.changedLanguage, object: nil)
            }
        }
    }
}
