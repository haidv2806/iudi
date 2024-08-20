import Foundation

// MARK: - UserData
struct UserData: Codable {
    let jwt, message: String?
    let status: Int?
    let user: User?
}
// MARK: - User
struct User: Codable {
    let users: [Users]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case users = "Users"
        case status
    }
}

// MARK: - UserElement
struct Users: Codable {
    let bio: String?
    let birthDate: String?
    let birthPlace: String?
    let birthTime: String?
    let currentAdd: String?
    let email, fullName, gender: String?
    let isLoggedIn: Bool
    let lastActivityTime, lastLoginIP, password, phone: String?
    let photoURL: [String]?
    let provinceID: Int?
    let registrationIP: String?
    let role: Bool?
    let userID: Int?
    let username: String?
    let avatarLink: String?

    enum CodingKeys: String, CodingKey {
        case bio = "Bio"
        case birthDate = "BirthDate"
        case birthPlace = "BirthPlace"
        case birthTime = "BirthTime"
        case currentAdd = "CurrentAdd"
        case email = "Email"
        case fullName = "FullName"
        case gender = "Gender"
        case isLoggedIn = "IsLoggedIn"
        case lastActivityTime = "LastActivityTime"
        case lastLoginIP = "LastLoginIP"
        case password = "Password"
        case phone = "Phone"
        case photoURL = "PhotoURL"
        case provinceID = "ProvinceID"
        case registrationIP = "RegistrationIP"
        case role = "Role"
        case userID = "UserID"
        case username = "Username"
        case avatarLink
    }
}


// MARK: - UserElement
struct UserElements: Codable {
    let birthDate, birthTime, email, fullName: String?
    let gender: String?
    let isLoggedIn: Bool?
    let lastActivityTime, lastLoginIP, password, phone: String?
    let provinceID: Int?
    let registrationIP: String?
    let role: Bool?
    let userID: Int?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case birthDate = "BirthDate"
        case birthTime = "BirthTime"
        case email = "Email"
        case fullName = "FullName"
        case gender = "Gender"
        case isLoggedIn = "IsLoggedIn"
        case lastActivityTime = "LastActivityTime"
        case lastLoginIP = "LastLoginIP"
        case password = "Password"
        case phone = "Phone"
        case provinceID = "ProvinceID"
        case registrationIP = "RegistrationIP"
        case role = "Role"
        case userID = "UserID"
        case username = "Username"
    }
}
struct SetAvatar: Codable {
    let newAvatar: String?
    let photoID: Int?
    let setAsAvatar: Bool?
    let userID: String?

    enum CodingKeys: String, CodingKey {
        case newAvatar = "NewAvatar"
        case photoID = "PhotoID"
        case setAsAvatar = "SetAsAvatar"
        case userID = "UserID"
    }
}
// MARK: - UserDataRespone
struct UserDataRespone: Codable {
    let message: String?
    let data: Users?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case data, status
    }
}


