//
//  Datas.swift
//  IUDI
//
//  Created by Quoc on 28/02/2024.
//

import Foundation

// MARK: - GroupData
struct GroupData: Codable {
    let data: [Datum]?
    let state: Int?
}

// MARK: - Datum
struct Datum: Codable {
    let createAt: String?
    let groupID: Int?
    let groupName: String?
    let userID: Int?
    let avatarLink: String?
    let userNumber: Int?
    
    enum CodingKeys: String, CodingKey {
        case createAt = "CreateAt"
        case groupID = "GroupID"
        case groupName = "GroupName"
        case userID = "UserID"
        case avatarLink, userNumber
    }
}

struct GroupDataPosts: Codable {
    let listPosts: [ListPost]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case listPosts = "list_posts"
        case status
    }
}

// MARK: - ListPost
struct ListPost: Codable {
    let avatar: String?
    let content: String?
    let firstComment: FirstComment?
    let groupID: Int?
    let ipPosted: String?
    let photo: String?
    let postID: Int?
    let postLatitude, postLongitude, postTime, title: String?
    let updatePostAt, userFullName: String?
    let userID: Int?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case avatar = "Avatar"
        case content = "Content"
        case firstComment = "FirstComment"
        case groupID = "GroupID"
        case ipPosted = "IPPosted"
        case photo = "Photo"
        case postID = "PostID"
        case postLatitude = "PostLatitude"
        case postLongitude = "PostLongitude"
        case postTime = "PostTime"
        case title = "Title"
        case updatePostAt = "UpdatePostAt"
        case userFullName = "UserFullName"
        case userID = "UserID"
        case username = "Username"
    }
}

// MARK: - FirstComment
struct FirstComment: Codable {
    let avatar: String?
    let content: String?
    let photo: String?
    let userFullName, username: String?

    enum CodingKeys: String, CodingKey {
        case avatar = "Avatar"
        case content = "Content"
        case photo = "Photo"
        case userFullName = "UserFullName"
        case username = "Username"
    }
}


struct PostData: Codable {
    let post: [Post]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case post = "Post"
        case status
    }
}

// MARK: - Post
struct Post: Codable {
    let content: String?
    let favoriteNumber, groupID: Int?
    let ipPosted: String?
    let photoURL: [String]?
    let postLatitude, postLongitude, postTime, title: String?
    let userID: Int?

    enum CodingKeys: String, CodingKey {
        case content = "Content"
        case favoriteNumber = "FavoriteNumber"
        case groupID = "GroupID"
        case ipPosted = "IPPosted"
        case photoURL = "PhotoURL"
        case postLatitude = "PostLatitude"
        case postLongitude = "PostLongitude"
        case postTime = "PostTime"
        case title = "Title"
        case userID = "UserID"
    }
}
