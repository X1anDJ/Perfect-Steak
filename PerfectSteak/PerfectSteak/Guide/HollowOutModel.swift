//
//  HollowOutModel.swift
//
//  Created by Dajun Xian on 7/24/23.
//

import UIKit

///  A data model for the hollow out userguide. Supporting UIView and UITableViewCell
final class HollowOutModel {
    internal init(type: RelativeType, playHandler: @escaping (Int) -> UIView) {
        self.type = type
        self.playHandler = playHandler
    }
    
    enum RelativeType {
        // A UIView is hollow out
        case view(UIView)
        // A UITableViewCell is hollow out
        case tableView(UITableView, IndexPath)
        // None view is hollow out
        case noneView
    }
    
    /// User guide steps
    var multipleStepCount = 1
    /// Hollow out view type
    let type: RelativeType
    /// Circle?
    var isCircle = false
    /// Distance between inner hollow out view and the dash line
    var insideMargin = UIEdgeInsets.zero
    /// Corner raduis
    var cornerRadius = 0.0
    /// Show dash line
    var isShowDashed = true
    /// Color of dash line
    var dashedColor = UIColor.white
    /// Width of dashline
    var dashedWidth = 1.5
    /// 在有效区域内自动滚动到合适位置（有效区域：参考NewUserGideTool的初始化方法）
    /// 仅限relativeView（挖空视图）被添加在滚动视图上
    /// 自动滚动的规则：
    /// relativeView.top 小于 有效区域的top时 滚动到最顶部
    /// relativeView.bottom 大于 有效区域的bottom时 滚动到最底部
    var autoAppropriateLocation = false
    /// Vertical margin between popview and hollow out view
    var verticalMargin = 20.0
    /// If pop view is under the hollow out view
    var isUnderRelativeView = true
    /// Closure of play setep. The return view width should equal to screen with because some views are not in the center.
    let playHandler: (Int) -> UIView
}
