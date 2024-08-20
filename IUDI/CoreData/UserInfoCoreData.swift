//
//  UserInfoCoreData.swift
//  IUDI
//
//  Created by LinhMAC on 12/04/2024.
//

import Foundation
import UIKit
import CoreData

class UserInfoCoreData {
    static let shared = UserInfoCoreData()
    private init (){}
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let userInfoFetchRequestResult = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfiles")
    let userInfoFetchRequestObject = NSFetchRequest<NSManagedObject>(entityName: "UserProfiles")
    func saveValue(){
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("lỗi lưu value: \(error)")
        }
    }
    
    func deleteCoreDataValue(){
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: userInfoFetchRequestResult)
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Lỗi khi xóa dữ liệu cũ từ CoreData: \(error)")
        }
    }
    func saveProfileValueToCoreData(userAvatarUrl: String?,userFullname: String?, userEmail: String?) {
        
        deleteCoreDataValue()
        // lưu dữ liệu vào FileManager
        guard let entity = NSEntityDescription.entity(forEntityName: "UserProfiles",in: managedContext) else {return }
        let userInfo = UserProfiles(entity: entity, insertInto: managedContext)
        userInfo.userFullName = userFullname
        userInfo.userAvatarUrl = userAvatarUrl
        userInfo.userEmail = userEmail
        saveValue()
    }
    func fetchProfileFromCoreData() -> UserProfiles? {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)
        let docsDir = dirPaths
        print("url core data \(docsDir)")

        let fetchRequest: NSFetchRequest<UserProfiles> = UserProfiles.fetchRequest()
        do {
            let profiles = try managedContext.fetch(fetchRequest)

            if let userProfile = profiles.first {
                return userProfile
            } else {
                // Trường hợp không tìm thấy bản ghi
                return nil
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }

}
