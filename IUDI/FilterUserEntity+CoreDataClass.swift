//
//  FilterUserEntity+CoreDataClass.swift
//  
//
//  Created by LinhMAC on 07/03/2024.
//
//

import Foundation
import CoreData

@objc(FilterUserEntity)
public class FilterUserEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FilterUserEntity> {
        return NSFetchRequest<FilterUserEntity>(entityName: "FilterUserEntity")
    }

    @NSManaged public var currentAddress: String?
    @NSManaged public var minDistance: Double
    @NSManaged public var maxDistance: Double
    @NSManaged public var minAge: Int32
    @NSManaged public var maxAge: Int32
    @NSManaged public var gender: String?

}
