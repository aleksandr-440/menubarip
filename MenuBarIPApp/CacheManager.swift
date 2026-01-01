//
//  CacheManager.swift
//  MenuBarIP
//
//  Created on macOS
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private var cachedResult: ResolvedIP?
    private var cacheTimestamp: Date?
    private let cacheDuration: TimeInterval = 3600 // 1 hour
    
    private init() {}
    
    func getCached() -> ResolvedIP? {
        guard let cached = cachedResult,
              let timestamp = cacheTimestamp,
              Date().timeIntervalSince(timestamp) < cacheDuration else {
            return nil
        }
        return cached
    }
    
    func setCache(_ result: ResolvedIP) {
        cachedResult = result
        cacheTimestamp = Date()
    }
    
    func clearCache() {
        cachedResult = nil
        cacheTimestamp = nil
    }
    
    func shouldRefresh() -> Bool {
        guard let timestamp = cacheTimestamp else {
            return true
        }
        return Date().timeIntervalSince(timestamp) >= cacheDuration
    }
}

