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
        return "Steak: \(thickness)cm, \(ovenTemp)°C"
    }
    
    var thickness: Double {
        didSet {
            if thickness < 0.5 {
                thickness = 0.5
            }
        }
    }
    
    var initialTemp: Double {
        didSet {
            if initialTemp < 0 {
                initialTemp = 0
            }
        }
    }
    
    var ovenTemp: Double {
        didSet {
            if ovenTemp < 100 {
                ovenTemp = 100
            }
        }
    }
    
    var desiredCenterTemp: Double {
        didSet {
            if desiredCenterTemp < 100 {
                desiredCenterTemp = 100
            }
        }
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
