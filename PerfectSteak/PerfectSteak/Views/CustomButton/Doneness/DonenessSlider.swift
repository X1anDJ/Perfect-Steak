//
//  DonenessSlider.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/26/23.
//

import UIKit

protocol SteakDonenessDelegate: AnyObject {
    func steakDonenessValueChanged(to value: SteakDoneness)
}

enum SteakDoneness: String {
    case rare = "Rare"
    case mediumRare = "Medium Rare"
    case medium = "Medium"
    case mediumWell = "Medium Well"
    case wellDone = "Well Done"
    
    var localized: String {
        L(rawValue)
    }
    
    static func temperatureFromDoneness(_ doneness: SteakDoneness) -> Double {
        switch doneness {
        case .rare:
            return 125.0
        case .mediumRare:
            return 135.0
        case .medium:
            return 145.0
        case .mediumWell:
            return 155.0
        case .wellDone:
            return 165.0
        }
    }
    
    static func fromTemperature(_ temperature: Double) -> SteakDoneness {
        switch temperature {
        case let t where t < 135.0:
            return .rare
        case let t where t < 145.0:
            return .mediumRare
        case let t where t < 155.0:
            return .medium
        case let t where t < 165.0:
            return .mediumWell
        default:
            return .wellDone
        }
    }
}

class DonenessSlider: UIView {
    
    @IBOutlet weak var parameterTitle: UILabel!
    @IBOutlet weak var steakDonenessTitle: UILabel!
    @IBOutlet weak var pointerView: UIView!
    var currentAngle: CGFloat = 0.0
    
    let minAngle: CGFloat = -150
    let maxAngle: CGFloat = -30
    let stepAngle: CGFloat = 30
    let animationDuration = 0.2
    let easingFunction: UIView.AnimationOptions = .curveEaseInOut
    var previousStepCount = 0
    let rotationSensitivity: CGFloat = 2.5   // smaller number gives more sensitivity
    
    let scaleRadius: CGFloat = 50
    
    weak var delegate: SteakDonenessDelegate?
    
    var currentDoneness: SteakDoneness {
        get {
            let temperature = temperatureFromAngle(currentAngle)
            return SteakDoneness.fromTemperature(temperature)
        }
        set {
            //print("current doneness is set: \(currentDoneness.rawValue)")
            // Convert the new doneness value to angle
            currentAngle = angleFromDoneness(newValue)
            updatePointerViewRotation()

            // Update the steakDonenessTitle directly
            steakDonenessTitle.text = newValue.localized
            delegate?.steakDonenessValueChanged(to: currentDoneness)
        }
    }
    
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
    
    func updateLanguage() {
        updateSteakDonenessTitle()
        parameterTitle.text = L("Doneness")
        steakDonenessTitle.text = currentDoneness.localized
        
    }

  
    @IBAction func handleButtonDragg(_ sender: UIPanGestureRecognizer) {
        //print("Doneness Dragged")
        //print("Current angle: \(currentAngle)")
        
        let translation = sender.translation(in: self)
        
        let angleDelta = translation.y / rotationSensitivity
        var angle = currentAngle - angleDelta
        angle = min(max(angle, minAngle), maxAngle)
        //print("Translation y: \(translation.y)")
        //print("Angle Delta: \(angleDelta)")
        //print("Angle: \(angle)")
        //print("")
        let stepCount = Int(round(angle / stepAngle))
    
        if stepCount != previousStepCount {
            sender.setTranslation(.zero, in: self)
            previousStepCount = stepCount
        }
        let stepAngleChange = CGFloat(stepCount) * stepAngle
        let newTransform = CGAffineTransform(rotationAngle: stepAngleChange * .pi / 180.0)
        //print("sender state: \(sender.state)")
        if sender.state == .changed {
            UIView.animate(withDuration: animationDuration , animations: {
            self.pointerView.transform = newTransform
                //print("pointerView transform: \(self.pointerView.transform )")

            })
            currentAngle = stepAngleChange
            
            updateSteakDonenessTitle()
            
            //print("doneness title: \(String(describing: steakDonenessTitle.text))")
            //print("current doneness: \(String(describing: currentDoneness))")
        }
        
    }
    
    private func updatePointerViewRotation() {
        let newTransform = CGAffineTransform(rotationAngle: currentAngle * .pi / 180.0)
        pointerView.transform = newTransform
    }
    
    private func angleFromDoneness(_ doneness: SteakDoneness) -> CGFloat {
        switch doneness {
        case .rare:
            return -150
        case .mediumRare:
            return -120
        case .medium:
            return -90
        case .mediumWell:
            return -60
        case .wellDone:
            return -30
        }
    }
    
    private func temperatureFromAngle(_ angle: CGFloat) -> Double {
        let stepCount = Int(round((angle - minAngle) / stepAngle))
        switch stepCount {
        case 0:
            return 125.0
        case 1:
            return 135.0
        case 2:
            return 145.0
        case 3:
            return 155.0
        case 4:
            return 165.0
        default:
            return 125.0
        }
    }

    
    private func updateSteakDonenessTitle() {
        steakDonenessTitle.text = currentDoneness.localized
        print("steak doneness: \(steakDonenessTitle.text)")
        let stepCount = Int(round((currentAngle - minAngle) / stepAngle))
        switch stepCount {
        case 0:
            //steakDonenessTitle.text = SteakDoneness.rare.rawValue
            currentDoneness = .rare
        case 1:
            //steakDonenessTitle.text = SteakDoneness.mediumRare.rawValue
            currentDoneness = .mediumRare
        case 2:
            //steakDonenessTitle.text = SteakDoneness.medium.rawValue
            currentDoneness = .medium
        case 3:
            //steakDonenessTitle.text = SteakDoneness.mediumWell.rawValue
            currentDoneness = .mediumWell
        case 4:
            //steakDonenessTitle.text = SteakDoneness.wellDone.rawValue
            currentDoneness = .wellDone
            
        default:
            break
        }
        
    }
    
}
