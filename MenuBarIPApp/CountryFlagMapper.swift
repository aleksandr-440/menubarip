//
//  CountryFlagMapper.swift
//  MenuBarIP
//
//  Created on macOS
//

import Foundation

struct CountryFlagMapper {
    static func flag(for countryCode: String?) -> String {
        guard let countryCode = countryCode?.uppercased(), countryCode.count == 2 else {
            return "🏴‍☠️"
        }
        
        let base: UInt32 = 127397
        var flag = ""
        
        for scalar in countryCode.unicodeScalars {
            guard let flagScalar = UnicodeScalar(base + scalar.value) else {
                return "🏴‍☠️"
            }
            flag.append(String(Character(flagScalar)))
        }
        
        return flag
    }
}

