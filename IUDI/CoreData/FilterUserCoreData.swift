//
//  FilterUserCoreData.swift
//  IUDI
//
//  Created by LinhMAC on 07/03/2024.
//

import Foundation
import UIKit
import CoreData

class FilterUserCoreData {
    static let share = FilterUserCoreData()
    private init() {}
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let filterUserFetchRequestResult = NSFetchRequest<NSFetchRequestResult>(entityName: "FilterUserEntity")
    let filterUserFetchRequestObject = NSFetchRequest<NSManagedObject>(entityName: "FilterUserEntity")
    
    func saveValue(){
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("lỗi lưu value: \(error)")
        }
    }
    
    func deleteLocationValue(){
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: filterUserFetchRequestResult)
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Lỗi khi xóa dữ liệu cũ từ CoreData: \(error)")
        }
    }
    
    func saveUserFilterValueToCoreData(currentAddress: String,minDistance: Double,maxDistance: Double,minAge: Int,maxAge: Int,gender: String) {
        deleteLocationValue()
        guard let entity = NSEntityDescription.entity(forEntityName: "FilterUserEntity",in: managedContext) else {return }
        let filterUserEntity = NSManagedObject(entity: entity,
                                                insertInto: managedContext)
        filterUserEntity.setValue(currentAddress, forKey: "currentAddress")
        filterUserEntity.setValue(minDistance, forKey: "minDistance")
        filterUserEntity.setValue(maxDistance, forKey: "maxDistance")
        filterUserEntity.setValue(minAge, forKey: "minAge")
        filterUserEntity.setValue(maxAge, forKey: "maxAge")
        filterUserEntity.setValue(gender, forKey: "gender")
        saveValue()
        print("saveValueToCoreData:\(currentAddress),\(minDistance),\(maxDistance),\(minAge),\(maxAge),\(gender)")
    }
    
    func getUserFilterValueFromCoreData(key: String) -> Any{
        do {
            let results = try managedContext.fetch(filterUserFetchRequestObject)
            for result in results {
                if let value = result.value(forKey: "\(key)") {
                    return value
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return ""
    }
}
