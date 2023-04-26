//
//  CircularSlider.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//

import UIKit

class CircularSlider: UIView {
    
    @IBOutlet weak var parameterTitle: UILabel!
    @IBOutlet weak var parameterNumber: UILabel!
    @IBOutlet weak var parameterUnit: UILabel!
    @IBOutlet weak var rangeBegin: UILabel!
    @IBOutlet weak var rangeEnd: UILabel!
    
    @IBOutlet weak var circularButton: UIButton!
    @IBOutlet weak var pointerView: UIView!
    
    //For the ring outside the button
    private var ringIndicatorLayer = CAShapeLayer()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
     
    
    private func loadFromNib() {
        print("loadFromNib called")
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))

        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            print("Failed to instantiate view from XIB")
            return
        }
        print("View instantiated from XIB")
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    

    
    private func configureViews() {
        // Add initial configurations for your views here, if needed.
        // For example, you could set default text or colors.
        parameterTitle.text = "Title"
        parameterUnit.text = "F"
        parameterNumber.text = "350"
        rangeBegin.text = "100"
        rangeEnd.text = "500"
    }

    
    private func drawRingIndicator(atAngle angle: CGFloat) {
        // Calculate the start and end points
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2
        let startAngle = -CGFloat.pi * 3 / 4 // -135 degrees
        let endAngle = angle

        // Create the ring path
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        // Update the ring indicator layer
        ringIndicatorLayer.path = path.cgPath
        ringIndicatorLayer.lineWidth = 4
        ringIndicatorLayer.strokeColor = UIColor.red.cgColor
        ringIndicatorLayer.fillColor = UIColor.clear.cgColor

        // Add the layer if it hasn't been added yet
        if ringIndicatorLayer.superlayer == nil {
            layer.addSublayer(ringIndicatorLayer)
        }
    }

    
    @IBAction func handleButtonDrag(_ sender: UIPanGestureRecognizer) {
        let touchLocation = sender.location(in: self)
        let centerX = bounds.midX
        let centerY = bounds.midY

        let deltaY = touchLocation.y - centerY
        let deltaX = touchLocation.x - centerX

        let angleInRadians = atan2(deltaY, deltaX)

        // Convert the angle to degrees and shift it by 210 degrees
        let angleInDegrees = (angleInRadians * 180 / .pi) - 210

        // Clamp the angle between 210 and 150 degrees
        let clampedAngleInDegrees = max(min(angleInDegrees, 150), 0)

        // Rotate the pointer hand
        let rotationTransform = CGAffineTransform(rotationAngle: (clampedAngleInDegrees + 210) * .pi / 180)
        pointerView.transform = rotationTransform

        // Update the ring indicator
        drawRingIndicator(atAngle: -CGFloat.pi * 3 / 4 + clampedAngleInDegrees * .pi / 180)
        
        // Map the angle to the desired number range and update the parameterNumber label
        let numberRange = 500 - 100
        let mappedNumber = 100 + Int(clampedAngleInDegrees / 150 * CGFloat(numberRange))
        parameterNumber.text = "\(mappedNumber)"
    }


}

