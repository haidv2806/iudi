//
//  UserDistance.swift
//  IUDI
//
//  Created by LinhMAC on 29/02/2024.
//

import Foundation

// MARK: - UserDistances
struct UserDistances: Codable {
    let distances: [Distance]?
    let userID, status: Int?

    enum CodingKeys: String, CodingKey {
        case distances = "Distances"
        case userID = "UserID"
        case status
    }
}

// MARK: - Distance
struct Distance: Codable {
    let bio, birthDate, birthPlace, birthTime: String?
    let currentAdd: String?
    let distance: Double?
    let email, fullName: String?
    let gender, lastActivityTime: String?
    let provinceID: Int?
    let userID: Int?
    let avatarLink: String?
    let isLoggedIn: Bool


    enum CodingKeys: String, CodingKey {
        case bio = "Bio"
        case birthDate = "BirthDate"
        case birthPlace = "BirthPlace"
        case birthTime = "BirthTime"
        case currentAdd = "CurrentAdd"
        case distance = "Distance"
        case email = "Email"
        case fullName = "FullName"
        case gender = "Gender"
        case lastActivityTime = "LastActivityTime"
        case provinceID = "ProvinceID"
        case userID = "UserID"
        case avatarLink
        case isLoggedIn = "IsLoggedIn"

    }
}
