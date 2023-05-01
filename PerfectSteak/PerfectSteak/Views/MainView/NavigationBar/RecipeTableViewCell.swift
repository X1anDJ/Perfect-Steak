//
//  RecipeTableViewCell.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/30/23.
//

import Foundation
import UIKit

class RecipeTableViewCell: UITableViewCell {
    
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
        let doneness = SteakDoneness.fromTemperature(recipe.desiredCenterTemp).rawValue
        titleLabel.text = String(format: "%.1f\" steak, %d °F stove, \n %d °F -> %@", recipe.thickness, Int(recipe.ovenTemp), Int(recipe.initialTemp), doneness)
    }
}
