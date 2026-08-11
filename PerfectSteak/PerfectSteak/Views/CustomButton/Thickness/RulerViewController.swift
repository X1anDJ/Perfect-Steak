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
    var appLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
    var initialLengthInInches: CGFloat = 1
    
    private var rulerView: RulerView!
    private var pointerView: UIView!
    private var lengthLabel: UILabel!
    //private let rulerHeight: CGFloat = 3 * pointsPerInch // Assuming pointsPerInch points per inch
    private var topPadding: CGFloat!
    
    private var pointsPerInch: CGFloat!
    private var rulerHeight: CGFloat!
    private let rulerLengthInch: CGFloat = 3
    private var horizontalLine: UIView!
    private var backgroundEffectView: UIVisualEffectView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupBackgroundMaterial()
        setupNavigationBarAppearance()
        setupUI()
    }

    private func setupBackgroundMaterial() {
        if #available(iOS 13.0, *) {
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
            effectView.frame = view.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(effectView)
            backgroundEffectView = effectView
        } else {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        }
    }

    private func setupNavigationBarAppearance() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hex: 0xFF5D32)]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        navigationController?.view.backgroundColor = .clear
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
        pointerView = ArrowView(frame: CGRect(x: rulerWidth, y: 0, width: 120, height: 80))
        pointerView.backgroundColor = .clear
        view.addSubview(pointerView)
        updatePointerPosition(for: initialLengthInInches)

        /*
        // Length label
        lengthLabel = UILabel(frame: CGRect(x: 0, y: view.safeAreaInsets.top - 125 + topPadding, width: view.frame.width, height: 45))
        lengthLabel.backgroundColor = .black
        lengthLabel.textAlignment = .center
        lengthLabel.text = "_._ inches" // Set the initial value to "0 inches"
        view.addSubview(lengthLabel)
        */
        
        //orange indicator line
        horizontalLine = UIView(frame: .zero)
        horizontalLine.backgroundColor = UIColor(hex: 0xFF5D32).withAlphaComponent(0.5)
        view.addSubview(horizontalLine)
        updateSelectionDisplay()

        // Close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(closeButtonTapped))

        // Add pan gesture recognizer
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pointerView.addGestureRecognizer(panGestureRecognizer)
    }



    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        pointerView.center = CGPoint(x: pointerView.center.x, y: min(max(pointerView.center.y + translation.y, topPadding), rulerHeight + topPadding))
        updateSelectionDisplay()
        gestureRecognizer.setTranslation(.zero, in: view)
    }

    private func updatePointerPosition(for length: CGFloat) {
        let clampedLength = min(max(length, 0), rulerLengthInch)
        let pointerY = topPadding + ((rulerLengthInch - clampedLength) * pointsPerInch)
        pointerView.center = CGPoint(x: pointerView.center.x, y: pointerY)
    }

    private func selectedLengthInInches() -> CGFloat {
        rulerLengthInch - ((pointerView.center.y - topPadding) / pointsPerInch)
    }

    private func updateSelectionDisplay() {
        let length = round(selectedLengthInInches() * 10) / 10
        let lengthInCmRounded = round(length * 2.54 * 10) / 10
        title = appLanguage == "en" ? "\(length) inches (\(lengthInCmRounded) cm)" : "\(length) 英寸 (\(lengthInCmRounded) cm)"
        horizontalLine.frame = CGRect(x: 0, y: pointerView.center.y, width: 180, height: -(pointerView.center.y - (topPadding + rulerHeight)))
    }

    @objc private func closeButtonTapped() {
        delegate?.didSelectLength(length: selectedLengthInInches())
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

final class RulerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private weak var sourceView: UIView?

    init(sourceView: UIView) {
        self.sourceView = sourceView
        super.init()
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        RulerPresentationAnimator(isPresenting: true, sourceView: sourceView)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        RulerPresentationAnimator(isPresenting: false, sourceView: sourceView)
    }
}

private final class RulerPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private weak var sourceView: UIView?

    init(isPresenting: Bool, sourceView: UIView?) {
        self.isPresenting = isPresenting
        self.sourceView = sourceView
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.32
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        let verticalOffset = transitionOffset(in: containerView)

        if isPresenting {
            guard let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }

            toView.frame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            toView.transform = CGAffineTransform(translationX: 0, y: verticalOffset)
            toView.alpha = 0
            containerView.addSubview(toView)

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: [.curveEaseOut]) {
                toView.transform = .identity
                toView.alpha = 1
            } completion: { finished in
                transitionContext.completeTransition(finished)
            }
        } else {
            guard let fromView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
            }

            UIView.animate(withDuration: duration * 0.8, delay: 0, options: [.curveEaseIn]) {
                fromView.transform = CGAffineTransform(translationX: 0, y: verticalOffset)
                fromView.alpha = 0
            } completion: { finished in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
    }

    private func transitionOffset(in containerView: UIView) -> CGFloat {
        guard let sourceView,
              let sourceSuperview = sourceView.superview else {
            return containerView.bounds.height
        }

        let sourceFrame = sourceSuperview.convert(sourceView.frame, to: containerView)
        return max(120, containerView.bounds.height - sourceFrame.midY)
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
