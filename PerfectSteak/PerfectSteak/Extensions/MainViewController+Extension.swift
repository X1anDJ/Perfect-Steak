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
        lengthLabel.text = "\(lengthRounded)"
        
        // Invalidate the previous timer if there's any
        updateTimer?.invalidate()

        // Update the countDownLabel immediately
        countDownLabel.text = "Meat thickness: \n \(lengthRounded)\""

        // Create a new timer to reset the countDownLabel after 1 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
}
