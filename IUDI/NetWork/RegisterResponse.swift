import Foundation
struct UserDataRegister: Codable {
    let users: [Users]?
    let status: Int?

    enum CodingKeys: String, CodingKey {
        case users = "Users"
        case status
    }
}
