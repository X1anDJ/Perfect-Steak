//
//  UIView+Extension.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//

import UIKit

extension UIView {
    @IBInspectable var  cornerRadius: CGFloat {
        get { return self.cornerRadius }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
