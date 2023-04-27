//
//  DonenessSlider.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/26/23.
//

import UIKit

enum SteakDoneness: String {
    case rare = "Rare"
    case mediumRare = "Medium Rare"
    case medium = "Medium"
    case mediumWell = "Medium Well"
    case wellDone = "Well Done"
}

enum SteakDonenessLabels: String, CaseIterable {
    case rare = "RRR"
    case mediumRare = "MR"
    case medium = "M"
    case mediumWell = "MW"
    case wellDone = "WWWW"
}


class DonenessSlider: UIView {

    @IBOutlet weak var steakDonenessTitle: UILabel!
    @IBOutlet weak var pointerView: UIView!
    
    var currentAngle: CGFloat = 0.0

    let minAngle: CGFloat = -90
    let maxAngle: CGFloat = 90
    let stepAngle: CGFloat = 45
    let scaleRadius: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
     
    
    private func loadFromNib() {
        //print("loadFromNib called")
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))

        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            print("Failed to instantiate view from XIB")
            return
        }
        //print("View instantiated from XIB")
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setupScaleLabels() {
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2

        for (index, doneness) in SteakDonenessLabels.allCases.enumerated() {
            let angle = minAngle + CGFloat(index) * stepAngle
            let angleInRadians = angle * .pi / 180

            let label = UILabel()
            label.text = doneness.rawValue
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .red
            label.sizeToFit()
            label.isUserInteractionEnabled = false
           // label.backgroundColor = .clear
            
            let labelCenterX = centerX + scaleRadius * cos(angleInRadians) - label.bounds.width / 2
            let labelCenterY = centerY - scaleRadius * sin(angleInRadians) - label.bounds.height / 2
            label.center = CGPoint(x: labelCenterX, y: labelCenterY)
            
            addSubview(label)
            bringSubviewToFront(label)
        }
    }

    
    
    
    @IBAction func handleButtonDragg(_ sender: UIPanGestureRecognizer) {
        print("Doneness Dragged")
        print("Current angle:\(currentAngle)" )
        let translation = sender.translation(in: self)
        let centerY = self.bounds.height / 2

        var angle = translation.y * 3 / centerY * 180.0
        angle = angle * (-1)
        angle = min(max(angle, minAngle - currentAngle), maxAngle - currentAngle)
        
        let stepCount = Int(round(angle / stepAngle))
        let stepAngleChange = CGFloat(stepCount) * stepAngle
        let newTransform = CGAffineTransform(rotationAngle: (currentAngle + stepAngleChange) * .pi / 180.0)
        // Animation added
        UIView.animate(withDuration: 0.3, animations: {
                    self.pointerView.transform = newTransform
                })

        // Update the current angle and steak doneness title in real-time
        currentAngle += stepAngleChange
        updateSteakDonenessTitle()

        // Reset the translation of the pan gesture to avoid compounding
        sender.setTranslation(.zero, in: self)
    }
    
    func updateSteakDonenessTitle() {
        let stepCount = Int(round((currentAngle - minAngle) / stepAngle))
        switch stepCount {
        case 0:
            steakDonenessTitle.text = SteakDoneness.rare.rawValue
        case 1:
            steakDonenessTitle.text = SteakDoneness.mediumRare.rawValue
        case 2:
            steakDonenessTitle.text = SteakDoneness.medium.rawValue
        case 3:
            steakDonenessTitle.text = SteakDoneness.mediumWell.rawValue
        case 4:
            steakDonenessTitle.text = SteakDoneness.wellDone.rawValue
        default:
            break
        }
    }

}
