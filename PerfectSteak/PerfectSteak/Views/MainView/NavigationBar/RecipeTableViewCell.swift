//
//  RecipeTableViewCell.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/30/23.
//

import Foundation
import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    var appLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "LiquidCrystal-Bold", size: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    
    
    func configure(with recipe: SteakRecipe) {
        let doneness = SteakDoneness.fromTemperature(recipe.desiredCenterTemp).localized

        if appLanguage == "en" {
            titleLabel.text = LF("Recipe Row Fahrenheit Format", recipe.thickness, Int(recipe.ovenTemp), Int(recipe.initialTemp), doneness)
        } else {
            let thicknessInCm = recipe.thickness * 2.54
            let ovenTempC = (recipe.ovenTemp - 32) * 5 / 9
            let initialTempC = (recipe.initialTemp - 32) * 5 / 9
            titleLabel.text = LF("Recipe Row Celsius Format", thicknessInCm, Int(ovenTempC), Int(initialTempC), doneness)
        }
    }

}
