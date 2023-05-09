//
//  SteakTemperature.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/28/23.
//

import UIKit

protocol SteakTemperatureDelegate: AnyObject {
    func steakTemperatureValueChanged(to value: CGFloat)
    func didTapButton()
}

protocol SteakTemperatureNumberPadDelegate: AnyObject {
    func showNumberPad(for steakTemperature: SteakTemperature)
}


class SteakTemperature: UIView, NumberPadViewDelegate {

    @IBOutlet weak var parameterTitle: UILabel!
    @IBOutlet weak var parameterNumber: UILabel!
    @IBOutlet weak var parameterUnit: UILabel!
    @IBOutlet weak var rangeBegin: UILabel!
    @IBOutlet weak var rangeEnd: UILabel!
    
    @IBOutlet weak var informationButton: UIButton!
    @IBOutlet weak var circularButton: UIButton!
    @IBOutlet weak var pointerView: UIView!
    
    //For the ring outside the button
    private var ringIndicatorLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    weak var numberPadDelegate: SteakTemperatureNumberPadDelegate?

    weak var delegate: SteakTemperatureDelegate?

    var onButtonTap: (() -> Void)?
    
    var currentAngle: CGFloat = 0.0
    
    var currentValue: CGFloat = 0.0 {
        didSet {
            parameterNumber.text = String(format: "%.0f", currentValue)
            currentAngle = angleFromValue(currentValue)
            updatePointerViewRotation()
            updateLayers()
            delegate?.steakTemperatureValueChanged(to: currentValue)
        }
    }
    
    
    let minValue: CGFloat = 0
    let maxValue: CGFloat = 120
    let minAngle: CGFloat = -150
    let maxAngle: CGFloat = 150
    
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
        configureViews()
        setupRing()
    }
    
    private func configureViews() {
        parameterTitle.text = "Meat Temperature"
        parameterUnit.text = "°F"
        parameterNumber.text = "75"
        rangeBegin.text = "0"
        rangeEnd.text = "120"
        //currentNumber = CGFloat(Double(parameterNumber.text ?? "0.0") ?? 0.0)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPointerView))
        pointerView.addGestureRecognizer(tapGestureRecognizer)
        pointerView.isUserInteractionEnabled = true
    }

    
    private func setupRing() {
        //print("Bounds: \(bounds), Frame: \(frame)")
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = 50.0
        let startAngle = (minAngle - 90) * .pi / 180
        let endAngle = (currentAngle + 60) * .pi / 180
           
        // Setup track layer
        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        trackLayer.path = trackPath.cgPath
        trackLayer.strokeColor = UIColor.gray.cgColor
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(trackLayer)
           
        // Setup progress layer
        //progressLayer.strokeColor = UIColor(red: 153/255, green: 255, blue: 170/255, alpha: 1).cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 5
        progressLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(progressLayer)
        
        if let parameterText = parameterNumber.text, let parameterValue = Double(parameterText) {
            currentAngle = angleFromValue(CGFloat(parameterValue))
            updateLayers()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }
    
    
    private func updateLayers() {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = 50.0
        let startAngle = (minAngle - 90) * .pi / 180
        let endAngle = (maxAngle - 90) * .pi / 180

        // Update track layer
        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        trackLayer.path = trackPath.cgPath

        // Update progress layer
        let progressStartAngle = (minAngle - 90) * .pi / 180
        let progressEndAngle = (currentAngle - 90) * .pi / 180
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: progressStartAngle, endAngle: progressEndAngle, clockwise: true)
        progressLayer.path = progressPath.cgPath
    }
    
    
    private func angleFromValue(_ value: CGFloat) -> CGFloat {
            let valueRange = maxValue - minValue
            let angleRange = maxAngle - minAngle
            let normalizedValue = (value - minValue) / valueRange
            return minAngle + (angleRange * normalizedValue)
    }
    


    private func updatePointerViewRotation() {
        let newTransform = CGAffineTransform(rotationAngle: currentAngle * .pi / 180.0)
        pointerView.transform = newTransform
    }
    
    private func updateParameterNumber() {
        let valueRange = maxValue - minValue
        let angleRange = maxAngle - minAngle
        let value = minValue + (valueRange * (currentAngle - minAngle) / angleRange)
        
       // value = round(value / 5) * 5
        currentValue = Double(value)
        parameterNumber.text = String(format: "%.0f", value)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapButton()
    }

    
    
    @IBAction func handleButtonDragg(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let centerY = self.bounds.height / 2 // adjust as needed

        var angle = translation.y / centerY * 180.0
        angle = angle * (-1)
        angle = min(max(angle, minAngle - currentAngle), maxAngle - currentAngle) // limit to -150 and 150 degrees
        let newTransform = CGAffineTransform(rotationAngle: (currentAngle + angle) * .pi / 180.0)
        pointerView.transform = newTransform

        // Update the current angle and parameter number in real-time
        currentAngle += angle
        updateParameterNumber()
        updateLayers()
        // Reset the translation of the pan gesture to avoid compounding
        sender.setTranslation(.zero, in: self)
        
        
    }
    
    func numberPadValueUpdated(to value: CGFloat) {
        let clampedValue = min(max(value, minValue), maxValue)
        currentValue = clampedValue
    }

    
    func didTapDoneButton() {
        if let mainViewController = numberPadDelegate as? MainViewController {
            mainViewController.dismissNumberPadView()
        }
    }

    @objc private func didTapPointerView() {
        numberPadDelegate?.showNumberPad(for: self)
    }
    
    

}
