//
//  HollowOutModel.swift
//
//  Created by Dajun Xian on 7/24/23.
//

import UIKit

/// 包装挖空位置的数据模型，被挖空的视图支持继承自UIView，UITableViewCell的类型
final class HollowOutModel {
    internal init(type: RelativeType, playHandler: @escaping (Int) -> UIView) {
        self.type = type
        self.playHandler = playHandler
    }
    
    enum RelativeType {
        // 挖空的是普通view类型
        case view(UIView)
        // 挖空的是UITableViewCell类型
        case tableView(UITableView, IndexPath)
        // 没有任何挖空区域
        case noneView
    }
    
    /// 挖空视图的类型
    let type: RelativeType
    /// 是否为圆形
    var isCircle = false
    /// 内边距(挖空视图到虚线的距离)
    var insideMargin = UIEdgeInsets.zero
    /// 显示步骤介绍的数量
    var multipleStepCount = 1
    /// 圆角
    var cornerRadius = 0.0
    /// 显示虚线
    var isShowDashed = true
    /// 虚线颜色(默认白色)
    var dashedColor = UIColor.white
    /// 虚线宽度
    var dashedWidth = 1.5
    /// 在有效区域内自动滚动到合适位置（有效区域：参考NewUserGideTool的初始化方法）
    /// 仅限relativeView（挖空视图）被添加在滚动视图上
    /// 自动滚动的规则：
    /// relativeView.top 小于 有效区域的top时 滚动到最顶部
    /// relativeView.bottom 大于 有效区域的bottom时 滚动到最底部
    var autoAppropriateLocation = false
    /// 弹出视图与挖空视图之间的垂直距离
    var verticalMargin = 20.0
    /// 弹出视图是否在挖空视图下面显示
    var isUnderRelativeView = true
    /// 播放步骤回调 返回的view宽度要等于屏幕宽度，因为有些视图并不是居中显示。
    let playHandler: (Int) -> UIView
}
