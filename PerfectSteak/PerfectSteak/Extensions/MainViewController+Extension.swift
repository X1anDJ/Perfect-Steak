//
//  MainViewController+Extension.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/28/23.
//

import UIKit

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MainViewController: RulerViewControllerDelegate {
    func didSelectLength(length: CGFloat) {
        
        guard timer == nil else { return }
              
        
        let lengthRounded = round(length * 10) / 10
        
        
        // Invalidate the previous timer if there's any
        updateTimer?.invalidate()

        // Update the countDownLabel immediately
        if usesFahrenheit {
            countDownLabel.text = LF("Meat Thickness Inches Status", lengthRounded)
            lengthLabel.text = "\(lengthRounded)"
        } else {
            let lengthInCm = lengthRounded * 2.54
            let lengthInCmRounded = round(lengthInCm * 10) / 10
            countDownLabel.text = LF("Meat Thickness Cm Status", lengthInCmRounded)
            lengthLabel.text = "\(lengthInCmRounded)"
        }
        // Create a new timer to reset the countDownLabel after 1 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
}
