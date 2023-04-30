//
//  ConcaveButton.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/28/23.
//
import UIKit

class ConcaveButton: UIButton {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = UIGraphicsGetCurrentContext()!
        
        let outerColor = UIColor.darkGray.cgColor
        let innerColor = UIColor.black.cgColor
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: [outerColor, innerColor] as CFArray, locations: [0, 1])
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2
        
        ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
        
        // Round the button's corners
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
