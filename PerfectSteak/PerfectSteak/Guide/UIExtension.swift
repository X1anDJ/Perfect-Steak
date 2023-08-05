//
//  UIColor+Extension.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 7/24/23.
//

import Foundation
import UIKit

extension UIColor {
    func alpha(_ alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
}

public extension UIEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

public final class LayoutConstants {
    public static var screenSize: CGSize { return UIScreen.main.bounds.size }
    public static var screenWidth: CGFloat { return UIScreen.main.bounds.width }
    public static var screenHeight: CGFloat { return UIScreen.main.bounds.height }
    public static var deviceWidth: CGFloat { Swift.min(screenWidth, screenHeight) }
    public static var deviceHeight: CGFloat { Swift.max(screenWidth, screenHeight) }
}


