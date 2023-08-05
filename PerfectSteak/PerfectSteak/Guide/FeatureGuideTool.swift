//
//  NewFeatureGideTool.swift
//
//  Created by Dajun Xian on 7/24/23.
//

import UIKit
/// 向用户展示新功能的介绍工具
final class FeatureGuideTool {
    
    enum ErrorCode {
        case noWindow
    }
    
    /// 缓存的唯一标识符
    private var identifier: String
    private var insideMargin: UIEdgeInsets
    private var dataSource: [HollowOutModel] = []
    private var currHollowOutModel: HollowOutModel?
    private var currStep = 1
    private static let newUserGideKey = "new.user.gide.cache.key"
    private lazy var bgView = UIView(frame: UIScreen.main.bounds)
    /// 用来挖空区域的View
    private lazy var maskView = UIView(frame: .zero)
    /// 蒙层的背景颜色
    private(set) var coverColor = UIColor.black.alpha(0.7)
    private var tempHollowOutLayer: CAShapeLayer?
    private var tempDashedLayer: CAShapeLayer?
    /// 完成回调
    public var completionHandler: (() -> Void)?
    /// 发生错误回调
    public var occurErrorHandler: ((ErrorCode) -> Void)?
    
    /// 构造函数
    /// - Parameters:
    ///   - identifier: 用于缓存的唯一标识符
    init(identifier: String, insideMargin: UIEdgeInsets) {
        self.identifier = identifier
        self.insideMargin = insideMargin
    }
}

// MARK: - Public
extension FeatureGuideTool {
    
    /// 调用此函数即开始执行新用户向导的逻辑显示
    /// - Parameter model: 模型数据
    func start(_ models: [HollowOutModel]) {
        guard !FeatureGuideTool.userGideFinished(identifier) else {
            completionHandler?()
            return print("\(identifier) 已经显示过新用户向导")
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
    
    /// 新用户向导是否完成过
    /// - Parameter key: 唯一标识符
    /// - Returns: 是否完成 true:完成，反之没有
    static func userGideFinished(_ key: String) -> Bool {
        if key.count == 0 {
            return false
        }
        guard let cacheDict = UserDefaults.standard.object(forKey: FeatureGuideTool.newUserGideKey) as? [String: Bool] else { return false }
        return cacheDict[key] ?? false
    }
    
    /// 清理缓存
    static func removeCache() {
        UserDefaults.standard.removeObject(forKey: newUserGideKey)
    }
}

// MARK: - Private
extension FeatureGuideTool {
    /// 执行下一步
    private func doNext() {
        guard dataSource.count > 0 else {
            completion()
            return
        }
        let hollowOutModel = dataSource.removeFirst()
        currHollowOutModel = hollowOutModel
        let popView = hollowOutModel.playHandler(currStep)
        hollowOutModel.multipleStepCount -= 1
        // 移除之前的子元素
        removeSubUI()
        // 显示挖空区域
        self.showHollowOutArea()
        // 添加popView
        self.addPopView(popView)
        // 标记此区域已经显示过新用户向导
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
    
    /// 显示挖空区域
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
            // 设置挖空区域
            let path = UIBezierPath(rect: UIScreen.main.bounds)
            let hollowOutPath = UIBezierPath(roundedRect: viewFrame, cornerRadius: hollowOutPathRadius)
            path.append(hollowOutPath)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillRule = .evenOdd
            maskView.layer.mask = shapeLayer
            
            // 设置虚线
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
    
    /// 添加弹出的popView
    /// - Parameter popView: 弹出的内容
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
            fatalError("popView 一定要设置宽度和高度")
        }
        let containerFrame = containerFrame(currModel)
        let popViewX = 0.0
        var popViewY = containerFrame.maxY + currModel.verticalMargin
        // 默认情况下popView都是显示在挖空区域的底部，如果底部位置不能够显示下popView则显示在上面
        if currModel.isUnderRelativeView {
            let bottomArea = safeAreaBottom(currModel) - containerFrame.maxY - currModel.verticalMargin
            if bottomArea < popViewHeight {
                // 显示不下，将弹出视图调整到挖空视图上面
                popViewY = containerFrame.minY - popViewHeight - currModel.verticalMargin
            }
        } else {
            // popView在挖空区域上面显示
            if containerFrame.minY > popViewHeight + currModel.verticalMargin {
                // 能显示下
                popViewY = containerFrame.minY - popViewHeight - currModel.verticalMargin
            }
        }
    
        switch currModel.type {
        case .noneView:
            // 默认情况下弹窗视图在全屏模式下是垂直居中的。如需要个性化设置，业务侧可以调整popView的高度来实现Y方向上的偏移
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
        // frame错误纠正
        viewFrame.origin.x = max(10, viewFrame.origin.x)
        viewFrame.size.width = min(bgView.frame.width - 20, viewFrame.size.width)
        
        return viewFrame
    }
    
    private func containerFrame(_ model: HollowOutModel) -> CGRect {
        let viewFrame = viewFrame(model)
        var containerFrame = viewFrame.inset(by: .init(top: -5, left: -5, bottom: -5, right: -5))
        // frame纠错
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
    
    /// 移除子UI元素
    private func removeSubUI() {
        // 移除之前的layer
        tempHollowOutLayer?.removeFromSuperlayer()
        tempDashedLayer?.removeFromSuperlayer()
        bgView.subviews.forEach {
            if $0 != maskView {
                $0.removeFromSuperview()
            }
        }
    }
    
    /// 存储新用户向导完成的标识
    /// - Parameter key: 唯一标识符
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
