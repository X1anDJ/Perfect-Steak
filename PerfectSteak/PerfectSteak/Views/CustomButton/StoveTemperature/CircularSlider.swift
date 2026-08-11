//
//  CircularSlider.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//

import UIKit

protocol CircularSliderDelegate: AnyObject {
    func circularSliderValueChanged(to value: CGFloat)
}

protocol CircularSliderNumberPadDelegate: AnyObject {
    func showNumberPad(for circularSlider: CircularSlider)
}

class CircularSlider: UIView, NumberPadViewDelegate {
    
    var appLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
    private var temperatureUnit = UserDefaults.standard.string(forKey: "TemperatureUnit") ?? "F"
    private var usesFahrenheit: Bool {
        temperatureUnit == "F"
    }
    
    @IBOutlet weak var parameterTitle: UILabel!
    @IBOutlet weak var parameterNumber: UILabel!
    @IBOutlet weak var parameterUnit: UILabel!
    @IBOutlet weak var rangeBegin: UILabel!
    @IBOutlet weak var rangeEnd: UILabel!
    
    @IBOutlet weak var circularButton: UIButton!
    @IBOutlet weak var pointerView: UIView!
    
    //For the ring outside the button
    private var ringIndicatorLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    
    weak var numberPadDelegate: CircularSliderNumberPadDelegate?

    
    var delegate: CircularSliderDelegate?
    
    var currentAngle: CGFloat = 0.0
    
    var currentValue: CGFloat = 0.0 {
        didSet {
            parameterNumber.text = String(format: "%.0f", currentValue)
            currentAngle = angleFromValue(currentValue)
            updatePointerViewRotation()
            updateLayers()
            delegate?.circularSliderValueChanged(to: currentValue)
        }
    }
    
    var minValue: CGFloat = 200
    var maxValue: CGFloat = 500
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
        configureViews()
        setupRing()
    }
    
    func updateLanguage() {
        appLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        temperatureUnit = UserDefaults.standard.string(forKey: "TemperatureUnit") ?? "F"
        configureViews()
    }
    
    private func toCelsius(_ temp: Int) -> Int {
        return Int(Double(temp - 32) * 5.0 / 9.0)
    }
    
    private func configureViews() {
        minValue = usesFahrenheit ? CGFloat(200) : CGFloat(toCelsius(200))
        maxValue = usesFahrenheit ? CGFloat(500) : CGFloat(toCelsius(500))
        parameterTitle.text = (appLanguage == "en") ? "Stove Temperature" : "烤箱温度"
        //print("Stove temperature appLanguage: \(appLanguage)")
        parameterUnit.text = usesFahrenheit ? "°F" : "°C"
        parameterNumber.text = usesFahrenheit ? "350" : String(toCelsius(350))
        rangeBegin.text = usesFahrenheit ? "200" : String(toCelsius(200))
        rangeEnd.text = usesFahrenheit ? "500" : String(toCelsius(500))
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
    
        
    
    // Updated the currentValue and parameter.text( title ) with the current angle
    
    private func updateParameterNumber() {
        let valueRange = maxValue - minValue
        let angleRange = maxAngle - minAngle
        let value = minValue + (valueRange * (currentAngle - minAngle) / angleRange)
        
        //value = round(value / 5) * 5
        currentValue = Double(value)
        parameterNumber.text = String(format: "%.0f", value)
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

