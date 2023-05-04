//
//  RulerViewController.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/27/23.
//

import UIKit
import DevicePpi

protocol RulerViewControllerDelegate: AnyObject {
    func didSelectLength(length: CGFloat)
}

class RulerViewController: UIViewController {
    
    weak var delegate: RulerViewControllerDelegate?
    
    private var rulerView: RulerView!
    private var pointerView: UIView!
    private var lengthLabel: UILabel!
    //private let rulerHeight: CGFloat = 3 * pointsPerInch // Assuming pointsPerInch points per inch
    private var topPadding: CGFloat!
    
    private var pointsPerInch: CGFloat!
    private var rulerHeight: CGFloat!
    private let rulerLengthInch: CGFloat = 3
    private var horizontalLine: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        setupUI()
        
        self.title = "_._ inches"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: 0xFF5D32)
        ]
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
    }
    
    private func setupUI() {
        
        let ppi: Double = {
            switch Ppi.get() {
            case .success(let ppi):
                return ppi
            case .unknown(let bestGuessPpi, _):
                // A bestGuessPpi value is provided but may be incorrect
                // Treat as a non-fatal error -- e.g. log to your backend and/or display a message
                return bestGuessPpi
            }
        }()
        
        pointsPerInch = CGFloat(ppi /  UIScreen.main.scale)
        rulerHeight = pointsPerInch * rulerLengthInch
        topPadding = view.frame.height - rulerHeight - view.safeAreaInsets.bottom - 100.0
          
        //print("ppi: \(String(describing: pointsPerInch))")
        //print("ppi from pod: \(ppi)")

        
        // Ruler view
        let rulerWidth: CGFloat = 180 // Change the width of the ruler's background
        rulerView = RulerView(frame: CGRect(x: 0, y: topPadding, width: rulerWidth, height: rulerHeight))
        rulerView.backgroundColor = .darkGray
        view.addSubview(rulerView)


        
        
        // Arrow-shaped pointer view
        pointerView = ArrowView(frame: CGRect(x: rulerWidth, y: topPadding+300, width: 120, height: 80))
        pointerView.backgroundColor = .clear
        view.addSubview(pointerView)

        /*
        // Length label
        lengthLabel = UILabel(frame: CGRect(x: 0, y: view.safeAreaInsets.top - 125 + topPadding, width: view.frame.width, height: 45))
        lengthLabel.backgroundColor = .black
        lengthLabel.textAlignment = .center
        lengthLabel.text = "_._ inches" // Set the initial value to "0 inches"
        view.addSubview(lengthLabel)
        */
        
        //orange indicator line
        let horizontalLineWidth: CGFloat = 180 // Same width as the rulerView
        let horizontalLineHeight: CGFloat = pointerView.center.y - (topPadding + rulerHeight)
        horizontalLine = UIView(frame: CGRect(x: 0, y: pointerView.center.y, width: horizontalLineWidth, height: -horizontalLineHeight))
        horizontalLine.backgroundColor = UIColor(hex: 0xFF5D32).withAlphaComponent(0.5)
        view.addSubview(horizontalLine)

        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Save", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.tintColor = UIColor.white
        let closeBarButtonItem = UIBarButtonItem(customView: closeButton)
        self.navigationItem.rightBarButtonItem = closeBarButtonItem

        // Add pan gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pointerView.addGestureRecognizer(panGestureRecognizer)
    }



    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)

        pointerView.center = CGPoint(x: pointerView.center.x, y: min(max(pointerView.center.y + translation.y, topPadding), rulerHeight + topPadding))

        var length = rulerLengthInch - ((pointerView.center.y - topPadding) / pointsPerInch)
        length = round(length * 10) / 10
        self.title = "\(length) inches"
        horizontalLine.frame = CGRect(x: 0, y: pointerView.center.y, width: horizontalLine.frame.width, height: -(pointerView.center.y - (topPadding + rulerHeight)))

        gestureRecognizer.setTranslation(.zero, in: view)
    }


    
    
    @objc private func closeButtonTapped() {
        delegate?.didSelectLength(length: rulerLengthInch - ((pointerView.center.y - topPadding) / pointsPerInch))
        dismiss(animated: true, completion: nil)
    }

}

class RulerView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ppi: Double = {
            switch Ppi.get() {
            case .success(let ppi):
                return ppi
            case .unknown(let bestGuessPpi, _):
                // A bestGuessPpi value is provided but may be incorrect
                // Treat as a non-fatal error -- e.g. log to your backend and/or display a message
                return bestGuessPpi
            }
        }()
        

        let lineWidth: CGFloat = 1
        let longLineLength: CGFloat = 150
        let shortLineLength: CGFloat = 60
        let gap: CGFloat  = ppi /  UIScreen.main.scale
        let padding: CGFloat = 0
        let rulerLengthInch: CGFloat = 3


        for i in 1...Int((rulerLengthInch * ppi) / (gap / (rulerLengthInch * rulerLengthInch))) {
            let yPosition = padding + CGFloat(i) * gap / (rulerLengthInch * rulerLengthInch)

            let shortLinePath = UIBezierPath()
            shortLinePath.lineWidth = lineWidth
            shortLinePath.move(to: CGPoint(x: 0, y: yPosition))
            shortLinePath.addLine(to: CGPoint(x: shortLineLength, y: yPosition))
            UIColor.gray.setStroke()
            shortLinePath.stroke()
        }
        
        for i in 0...Int(rulerLengthInch) {
            let yPosition = padding + CGFloat(i) * gap

            // Long line for each inch
            let longLinePath = UIBezierPath()
            longLinePath.lineWidth = lineWidth
            longLinePath.move(to: CGPoint(x: 0, y: yPosition))
            longLinePath.addLine(to: CGPoint(x: longLineLength, y: yPosition))
            UIColor.lightGray.setStroke()
            longLinePath.stroke()

            let labelText = "\(Int(rulerLengthInch) - i)"
            let label = UILabel(frame: CGRect(x: longLineLength + 2, y: yPosition - 8, width: 24, height: 16))
            label.font = UIFont.systemFont(ofSize: 20)
            label.text = labelText
            label.textColor = UIColor.lightGray
            label.textAlignment = .left
            addSubview(label)
        }
    }
}

class ArrowView: UIView {
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()

        path.move(to: CGPoint(x: 0, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.close()

        
        let fillColor = UIColor(hex: 0xFF5D32)
        fillColor.setFill()
        path.fill()
    }
}

//convert hex to rgb
extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
