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
        return "\(thickness) Inch \(ovenTemp)°F desiredCenterTemp: \(SteakDoneness.fromTemperature(ovenTemp)) ovenTemperature: \(ovenTemp)"
    }
    
    var thickness: Double
    
    var initialTemp: Double
    
    var ovenTemp: Double
    
    var desiredCenterTemp: Double 
    
    
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
