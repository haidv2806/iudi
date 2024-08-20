//
//  ChatRepsone.swift
//  IUDI
//
//  Created by LinhMAC on 31/03/2024.
//

import Foundation

struct AllChatData: Codable {
    let data: [ChatData]
    let status: Int?
}

// MARK: - Datum
struct ChatData: Codable {
    let avatar: String?
    let content, email: String?
    let image: String?
    let isSeen, messageID: Int?
    let messageTime: String?
    let otherAvatar: String?
    let otherEmail, otherFullname: String?
    let otherLastActivityTime: String?
    let otherUserID: Int?
    let otherUsername: String?
    let receiverID, senderID, userID: Int?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case avatar = "Avatar"
        case content = "Content"
        case email = "Email"
        case image = "Image"
        case isSeen = "IsSeen"
        case messageID = "MessageID"
        case messageTime = "MessageTime"
        case otherAvatar = "OtherAvatar"
        case otherEmail = "OtherEmail"
        case otherFullname = "OtherFullname"
        case otherLastActivityTime = "OtherLastActivityTime"
        case otherUserID = "OtherUserID"
        case otherUsername = "OtherUsername"
        case receiverID = "ReceiverID"
        case senderID = "SenderID"
        case userID = "UserID"
        case username = "Username"
    }
}
struct AllSingleChatData: Codable {
    let data: [SingleChat]
    let status: Int?
}

// MARK: - Datum
struct SingleChat: Codable {
    let avatar: String?
    let content, email: String?
    let image: String?
    let isSeen, messageID: Int?
    let messageTime: String?
    let otherAvatar: String?
    let otherEmail, otherFullName, otherLastActivityTime, otherUserID: String?
    let otherUsername: String?
    let receiverID, senderID, userID: Int?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case avatar = "Avatar"
        case content = "Content"
        case email = "Email"
        case image = "Image"
        case isSeen = "IsSeen"
        case messageID = "MessageID"
        case messageTime = "MessageTime"
        case otherAvatar = "OtherAvatar"
        case otherEmail = "OtherEmail"
        case otherFullName = "OtherFullName"
        case otherLastActivityTime = "OtherLastActivityTime"
        case otherUserID = "OtherUserID"
        case otherUsername = "OtherUsername"
        case receiverID = "ReceiverID"
        case senderID = "SenderID"
        case userID = "UserID"
        case username = "Username"
    }
}
