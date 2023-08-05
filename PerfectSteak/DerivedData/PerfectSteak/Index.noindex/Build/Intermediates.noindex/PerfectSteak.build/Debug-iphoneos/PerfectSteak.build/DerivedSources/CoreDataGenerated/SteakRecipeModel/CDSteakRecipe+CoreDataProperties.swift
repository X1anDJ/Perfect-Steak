//
//  CDSteakRecipe+CoreDataProperties.swift
//  
//
//  Created by Dajun Xian on 2023/8/5.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CDSteakRecipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSteakRecipe> {
        return NSFetchRequest<CDSteakRecipe>(entityName: "CDSteakRecipe")
    }

    @NSManaged public var desiredCenterTemp: Double
    @NSManaged public var id: UUID?
    @NSManaged public var initialTemp: Double
    @NSManaged public var ovenTemp: Double
    @NSManaged public var thickness: Double

}

extension CDSteakRecipe : Identifiable {

}
