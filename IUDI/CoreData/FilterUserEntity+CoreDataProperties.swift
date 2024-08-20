//
//  FilterUserEntity+CoreDataProperties.swift
//  
//
//  Created by Quoc on 1/4/24.
//
//

import Foundation
import CoreData


extension FilterUserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FilterUserEntity> {
        return NSFetchRequest<FilterUserEntity>(entityName: "FilterUserEntity")
    }

    @NSManaged public var currentAddress: String?
    @NSManaged public var gender: String?
    @NSManaged public var maxAge: Int32
    @NSManaged public var maxDistance: Double
    @NSManaged public var minAge: Int32
    @NSManaged public var minDistance: Double

}
