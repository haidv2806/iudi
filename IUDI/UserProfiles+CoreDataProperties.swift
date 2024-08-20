//
//  UserProfiles+CoreDataProperties.swift
//  
//
//  Created by LinhMAC on 12/04/2024.
//
//

import Foundation
import CoreData


extension UserProfiles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfiles> {
        return NSFetchRequest<UserProfiles>(entityName: "UserProfiles")
    }

    @NSManaged public var userAvatarUrl: String?
    @NSManaged public var userFullName: String?
    @NSManaged public var userEmail: String?

}
