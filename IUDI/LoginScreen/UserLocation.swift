//
//  UserLocation.swift
//  IUDI
//
//  Created by LinhMAC on 03/03/2024.
//

import Foundation
struct UserLocation: Codable {
    let status, country, countryCode, region: String?
    let regionName, city, zip: String?
    let lat, lon: Double?
    let timezone, isp, org, userLocationAs: String?
    let query: String?

    enum CodingKeys: String, CodingKey {
        case status, country, countryCode, region, regionName, city, zip, lat, lon, timezone, isp, org
        case userLocationAs = "as"
        case query
    }
}
