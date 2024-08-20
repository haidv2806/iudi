//
//  UserInfo.swift
//  IUDI
//
//  Created by LinhMAC on 19/03/2024.
//

import Foundation
import KeychainSwift

class UserInfo{
    static let shared = UserInfo()
    let keychain = KeychainSwift()

    private init(){}
    
    // lưu user
    func saveUserName(userName: String){
        keychain.set(userName, forKey: "username")
    }
    
    func saveUserPassword(password: String){
        keychain.set(password, forKey: "password")
    }
    
    func saveUserID(userID: String){
        keychain.set(String(userID), forKey: "userID")
    }
    func saveUserFullName(userFullName: String){
        keychain.set(String(userFullName), forKey: "userFullName")
    }
    
    //lấy thông tin  user
    func getUserName() -> String?{
        let userName = keychain.get("username")
        return userName
    }
    
    func getUserPassword() -> String?{
        let password = keychain.get("password")
        return password
    }
    
    func getUserID() -> String?{
        let userID = keychain.get("userID")
        return userID
    }
    func getUserFullName() -> String?{
        let userID = keychain.get("userFullName")
        return userID
    }
    // xóa thông tin user
    func deleteUserPw(){
        keychain.delete("password")
    }
    
}
