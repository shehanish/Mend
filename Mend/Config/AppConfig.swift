//
//  AppConfig.swift
//  Mend
//
//  Created by Shehani Hansika on 12.05.26.
//


import Foundation

enum AppConfig {
    static var apiKey: String {
        guard let rawKey = Bundle.main.object(forInfoDictionaryKey: "MYAPI_KEY") as? String else {
            fatalError("MYAPI_KEY not found in Info.plist at all.")
        }
        
        // Defensively strip out any double quotes or extra whitespace that Xcode might have cached
        let key = rawKey.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !key.isEmpty, !key.contains("put-your-key-here"), !key.contains("$(MYAPI_KEY)") else {
            fatalError("Missing or invalid MYAPI_KEY. Current value: '\(key)'. Check Secrets.xcconfig and clean build.")
        }
        return key
    }
}