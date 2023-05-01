//
//  SteakRecipe.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/24/23.
//

import Foundation

class SteakRecipe {
    
    var ID = UUID()
    
    var title: String {
        return "My Recepies"
    }
    
    var thickness: Double
    
    var initialTemp: Double
    
    var ovenTemp: Double
    
    var desiredCenterTemp: Double 
    
    
    var doneness: SteakDoneness {
        return SteakDoneness.fromTemperature(desiredCenterTemp)
    }

    
    init(ID: UUID, thickness: Double, initialTemp: Double, ovenTemp: Double, desiredCenterTemp: Double) {
        self.ID = ID
        self.thickness = thickness
        self.initialTemp = initialTemp
        self.ovenTemp = ovenTemp
        self.desiredCenterTemp = desiredCenterTemp
    }
    
    init(thickness: Double, initialTemp: Double, ovenTemp: Double, desiredCenterTemp: Double) {
        self.thickness = thickness
        self.initialTemp = initialTemp
        self.ovenTemp = ovenTemp
        self.desiredCenterTemp = desiredCenterTemp
    }
    
    init(cdSteakRecipe: CDSteakRecipe) {
        self.ID = cdSteakRecipe.id!
        self.thickness = cdSteakRecipe.thickness
        self.initialTemp = cdSteakRecipe.initialTemp
        self.ovenTemp = cdSteakRecipe.ovenTemp
        self.desiredCenterTemp = cdSteakRecipe.desiredCenterTemp
    }

}
