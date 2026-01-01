//
//  Models.swift
//  MenuBarIP
//
//  Created on macOS
//

import Foundation

struct IPResponse: Codable {
    let ip: String
    let countryCode: String?
    let country: String?
    let countryName: String?
    
    enum CodingKeys: String, CodingKey {
        case ip
        case countryCode = "country_code"
        case country
        case countryName = "country_name"
    }
}

struct GeoLocation: Codable {
    let ip: String
    let countryCode: String?
    
    init(ip: String, countryCode: String? = nil) {
        self.ip = ip
        self.countryCode = countryCode
    }
}

struct APIResult {
    let ip: String?
    let countryCode: String?
    let countryName: String?
    let source: String
    let error: Error?
    
    init(ip: String? = nil, countryCode: String? = nil, countryName: String? = nil, source: String, error: Error? = nil) {
        self.ip = ip
        self.countryCode = countryCode
        self.countryName = countryName
        self.source = source
        self.error = error
    }
}

struct ResolvedIP {
    let ip: String
    let countryCode: String?
    let countryName: String?
    let flag: String
}

