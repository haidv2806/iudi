//
//  CheckValid.swift
//  IUDI
//
//  Created by LinhMAC on 23/02/2024.
//

import Foundation

protocol CheckValid {
    func checkUserNameValid(userName: String) -> Bool
    func passwordValidator(password: String) -> Bool
    func emailValidator(email: String) -> Bool
}
extension CheckValid {
    // hàm check valid userName
    func checkUserNameValid(userName: String) -> Bool {
        if isValidUserName(userName) {
            return true
        } else {
            return false
        }
    }
    //Regex check username ( user name phải viết liền, không có tiếng việt, chỉ chữ cái latin và số , không có ký tự đặc biệt )
    func isValidUserName(_ userName: String) -> Bool {
        let regex = "^[a-zA-Z0-9]+$"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: userName)
    }
    
    // kiểm tra thông tin mật khẩu  User nhập
    func passwordValidator(password: String) -> Bool {
        if password.count < 1 {
            return false
        } else {
            return true
        }
    }
    
    // hàm check định dạng email
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    // kiểm tra thông tin email  User nhập , trả về message để gán vào eror text, giá trị bool để gán vào hàm xử lí UI phía dưới
    func emailValidator(email: String) -> Bool {
        if email.isEmpty {
            return false
        } else if !isValidEmail(email) {
            return false
        } else {
            return true
        }
    }
}
