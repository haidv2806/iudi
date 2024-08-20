//
//  getAllImage.swift
//  IUDI
//
//  Created by LinhMAC on 28/02/2024.
//

import Foundation

// MARK: - GroupData
struct GetPhotos: Codable {
    let photos: [Photo]?
    let userID: String?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case photos = "Photos"
        case userID = "UserID"
        case status
    }
}

// MARK: - Photo
struct Photo: Codable {
    let photoID: Int?
    let photoURL: String?
    let setAsAvatar: Bool?
    let uploadTime: String?

    enum CodingKeys: String, CodingKey {
        case photoID = "PhotoID"
        case photoURL = "PhotoURL"
        case setAsAvatar = "SetAsAvatar"
        case uploadTime = "UploadTime"
    }
}
