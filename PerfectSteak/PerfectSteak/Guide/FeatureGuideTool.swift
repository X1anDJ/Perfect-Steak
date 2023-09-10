//
//  NewFeatureGideTool.swift
//
//  Created by Dajun Xian on 7/24/23.
//

import UIKit
/// A tool for introducing 
final class FeatureGuideTool {
    
    enum ErrorCode {
        case noWindow
    }
    
    /// unique identifier
    private var identifier: String
    private var insideMargin: UIEdgeInsets
    private var dataSource: [HollowOutModel] = []
    private var currHollowOutModel: HollowOutModel?
    private var currStep = 1
    private static let newUserGideKey = "new.user.gide.cache.key"
    private lazy var bgView = UIView(frame: UIScreen.main.bounds)
    /// view for hallow
    private lazy var maskView = UIView(frame: .zero)
    /// mask's color
    private(set) var coverColor = UIColor.black.alpha(0.7)
    private var tempHollowOutLayer: CAShapeLayer?
    private var tempDashedLayer: CAShapeLayer?
    /// completion
    public var completionHandler: (() -> Void)?
    public var occurErrorHandler: ((ErrorCode) -> Void)?
    
    /// - Parameters:
    ///   - identifier: Unique Identifier
    init(identifier: String, insideMargin: UIEdgeInsets) {
        self.identifier = identifier
        self.insideMargin = insideMargin
    }
}

// MARK: - Public
extension FeatureGuideTool {
    
    /// Call this fuctoin to execute new user guide
    /// - Parameter model:
    func start(_ models: [HollowOutModel]) {
        guard !FeatureGuideTool.userGideFinished(identifier) else {
            completionHandler?()
            return print("\(identifier) New user guide is already showed")
        }
        
        guard models.count != 0 else {
            completionHandler?()
            return
        }

        DispatchQueue.main.async {
            self.dataSource.removeAll()
            self.dataSource.append(contentsOf: models)
            guard let window = UIWindow.keyWindow else {
                self.occurErrorHandler?(.noWindow)
                return
            }
            
            self.bgView.backgroundColor = .clear
            window.addSubview(self.bgView)

            self.maskView.backgroundColor = self.coverColor
            self.maskView.frame = CGRect(x: 0, y: 0, width: self.bgView.frame.size.width, height: self.bgView.frame.size.height)
            self.bgView.addSubview(self.maskView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.sureTapClick))
            self.bgView.addGestureRecognizer(tap)
            
            self.doNext()
        }
    }
    
    /// Check if the new user guide is showed
    /// - Parameter key: unique identifier
    /// - Returns: completed?: true
    static func userGideFinished(_ key: String) -> Bool {
        if key.count == 0 {
            return false
        }
        guard let cacheDict = UserDefaults.standard.object(forKey: FeatureGuideTool.newUserGideKey) as? [String: Bool] else { return false }
        return cacheDict[key] ?? false
    }
    
    /// remove cache
    static func removeCache() {
        UserDefaults.standard.removeObject(forKey: newUserGideKey)
    }
}

// MARK: - Private
extension FeatureGuideTool {
    ///  Execute next step
    private func doNext() {
        guard dataSource.count > 0 else {
            completion()
            return
        }
        let hollowOutModel = dataSource.removeFirst()
        currHollowOutModel = hollowOutModel
        let popView = hollowOutModel.playHandler(currStep)
        hollowOutModel.multipleStepCount -= 1
        // Remove previous sub UI
        removeSubUI()
        // Show hollow out area
        self.showHollowOutArea()
        // Add PopView
        self.addPopView(popView)
        // Mark the user guide is showed with a tag and identifier
        saveUserGideFinishedTag(identifier)
    }
    
    private func completion() {
        UIView.animate(withDuration: 0.25) {
            self.bgView.alpha = 0.0
        } completion: { _ in
            self.completionHandler?()
            self.bgView.removeFromSuperview()
        }
    }
    
    @objc private func sureTapClick() {
        if let currModel = currHollowOutModel, currModel.multipleStepCount > 0 {
            currStep += 1
            let popView = currModel.playHandler(currStep)
            addPopView(popView)
            currModel.multipleStepCount -= 1
        } else {
            currStep = 1
            doNext()
        }
    }
    
    /// Show hollow out area
    private func showHollowOutArea() {
        guard let currModel = currHollowOutModel else { return }
        switch currModel.type {
        case .noneView:
            return
        default:
            let hollowOutModel = currModel
            let isCircle = hollowOutModel.isCircle
            let viewFrame = viewFrame(currModel)
            let containerFrame = containerFrame(currModel)
            let hollowOutPathRadius = isCircle ? viewFrame.width / 2.0 : hollowOutModel.cornerRadius
            let dashedCornerRadius = isCircle ? containerFrame.width / 2.0 : hollowOutModel.cornerRadius
            // Setup hollowout area
            let path = UIBezierPath(rect: UIScreen.main.bounds)
            let hollowOutPath = UIBezierPath(roundedRect: viewFrame, cornerRadius: hollowOutPathRadius)
            path.append(hollowOutPath)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillRule = .evenOdd
            maskView.layer.mask = shapeLayer
            
            // Setup dashed layer
            guard hollowOutModel.isShowDashed else { return }
            let dashedLayer = CAShapeLayer()
            let bounds = CGRect(x: 0, y: 0, width: containerFrame.size.width, height: containerFrame.size.height)
            dashedLayer.frame = containerFrame
            dashedLayer.fillColor = UIColor.clear.cgColor
            dashedLayer.strokeColor = hollowOutModel.dashedColor.cgColor
            dashedLayer.lineWidth = hollowOutModel.dashedWidth
            dashedLayer.lineJoin = CAShapeLayerLineJoin.round
            dashedLayer.lineDashPattern = [4, 4]
            dashedLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(dashedCornerRadius)).cgPath
            maskView.layer.addSublayer(dashedLayer)
            
            tempHollowOutLayer = shapeLayer
            tempDashedLayer = dashedLayer
        }
    }
    
    /// Add popView
    /// - Parameter popView: contents that pops up
    private func addPopView(_ popView: UIView) {
        guard let currModel = currHollowOutModel else { return }
        bgView.subviews.forEach {
            if $0 != maskView {
                $0.removeFromSuperview()
            }
        }
        bgView.addSubview(popView)
        let popViewWidth = popView.bounds.size.width
        let popViewHeight = popView.bounds.size.height
        if popViewWidth == 0 || popViewHeight == 0 {
            fatalError("popView should setup wid and height")
        }
        let containerFrame = containerFrame(currModel)
        let popViewX = 0.0
        var popViewY = containerFrame.maxY + currModel.verticalMargin
        // In default case, popView shows under hollowout area. If the popView is out of bound of the bottom area, it shows above.
        if currModel.isUnderRelativeView {
            let bottomArea = safeAreaBottom(currModel) - containerFrame.maxY - currModel.verticalMargin
            if bottomArea < popViewHeight {
                // Out of bound. Popview moves to the top of hollowout view
                popViewY = containerFrame.minY - popViewHeight - currModel.verticalMargin
            }
        } else {
            // popView shows above hollow out area
            if containerFrame.minY > popViewHeight + currModel.verticalMargin {
                // Not out of bound
                popViewY = containerFrame.minY - popViewHeight - currModel.verticalMargin
            }
        }
    
        switch currModel.type {
        case .noneView:
            // In default case, popout view shows in center.
            popViewY = (bgView.frame.height - popViewHeight) / 2.0
        default:
            break
        }
        
        popView.frame = CGRect(x: popViewX, y: popViewY, width: popViewWidth, height: popViewHeight)
    }
        
    private func viewFrame(_ model: HollowOutModel) -> CGRect {
        guard let window = UIWindow.keyWindow else { return .zero }
        var relayViewFrame = CGRect.zero
        switch model.type {
        case .noneView:
            relayViewFrame = .zero
            
        case let .view(view):
            if view.bounds.size.width == 0 || view.bounds.size.height == 0 {
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
            relayViewFrame = view.convert(view.bounds, to: window)
            
        case let .tableView(tableView, indexPath):
            if tableView.bounds.size.width == 0 || tableView.bounds.size.height == 0 {
                tableView.setNeedsLayout()
                tableView.layoutIfNeeded()
            }
            let rectInTableView = tableView.rectForRow(at: indexPath)
            relayViewFrame = tableView.convert(rectInTableView, to: window)
        }
        var viewFrame = relayViewFrame.inset(
            by: .init(
                top: -model.insideMargin.top,
                left: -model.insideMargin.left,
                bottom: -model.insideMargin.bottom,
                right: -model.insideMargin.right
            )
        )
        // Correct the frame error
        viewFrame.origin.x = max(10, viewFrame.origin.x)
        viewFrame.size.width = min(bgView.frame.width - 20, viewFrame.size.width)
        
        return viewFrame
    }
    
    private func containerFrame(_ model: HollowOutModel) -> CGRect {
        let viewFrame = viewFrame(model)
        var containerFrame = viewFrame.inset(by: .init(top: -5, left: -5, bottom: -5, right: -5))
        // Correct the frame error
        containerFrame.origin.x = max(5, containerFrame.origin.x)
        containerFrame.size.width = viewFrame.size.width + 10
        return containerFrame
    }
    
    private func safeAreaTop(_ model: HollowOutModel) -> CGFloat {
        bgView.frame.minY + model.insideMargin.top
    }
    
    private func safeAreaBottom(_ model: HollowOutModel) -> CGFloat {
        bgView.frame.maxY - model.insideMargin.bottom
    }
    
    /// Remove sub UI
    private func removeSubUI() {
        // Remove previous layer
        tempHollowOutLayer?.removeFromSuperlayer()
        tempDashedLayer?.removeFromSuperlayer()
        bgView.subviews.forEach {
            if $0 != maskView {
                $0.removeFromSuperview()
            }
        }
    }
    
    /// Store unique id when user completed guide
    /// - Parameter key: unique id
    private func saveUserGideFinishedTag(_ key: String) {
        var cacheDict = UserDefaults.standard.object(forKey: FeatureGuideTool.newUserGideKey) as? [String: Bool]
        if cacheDict == nil {
            cacheDict = [:]
        }
        cacheDict![key] = true
        UserDefaults.standard.set(cacheDict!, forKey: FeatureGuideTool.newUserGideKey)
        UserDefaults.standard.synchronize()
    }
}
