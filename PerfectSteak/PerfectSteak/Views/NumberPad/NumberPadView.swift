//
//  NumberPadView.swift
//  SteakScience
//
//  Created by Dajun Xian on 5/8/23.
//

import UIKit


protocol NumberPadViewDelegate: AnyObject {
    func numberPadValueUpdated(to value: CGFloat)
    func didTapDoneButton()
}

class NumberPadView: UIView {
    
    private var firstButtonPress = true
    
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: NumberPadViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        loadFromNib()
    }

    
    private func loadFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            print("Failed to instantiate view from XIB")
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    @IBAction func numberButonTapped(_ sender: UIButton) {
        let numberText = String(sender.tag)
        
        // Don't allow leading zero
        if numberText == "0" && textField.text == "" {
            return
        }
        
        if firstButtonPress {
            textField.text = ""
            firstButtonPress = false
        }
        
        if textField.text!.count < 3 {
            textField.text = textField.text! + numberText
        }
        
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        textField.text = String(textField.text!.dropLast())
    }
    
    @IBAction func incrementBy5(_ sender: UIButton) {
        if let currentValue = textField.text, let value = Int(currentValue) {
            textField.text = String(value + 5)
        }
    }
    
    @IBAction func decrementBy5(_ sender: UIButton) {
        if let currentValue = textField.text, let value = Int(currentValue) {
            textField.text = String(max(0, value - 5))
        }
    }
    
    @IBAction func incrementBy1(_ sender: UIButton) {
        if let currentValue = textField.text, let value = Int(currentValue) {
            textField.text = String(value + 1)
        }
    }
    
    @IBAction func decrementBy1(_ sender: UIButton) {
        if let currentValue = textField.text, let value = Int(currentValue) {
            textField.text = String(value - 1)
        }
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        doneButtonTapped(sender)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        textField.text = ""
        didTapDoneButton()
    }
    
    private func doneButtonTapped(_ sender: UIButton) {
        if let currentValue = textField.text, let value = Double(currentValue) {
            delegate?.numberPadValueUpdated(to: CGFloat(value))
        }
        delegate?.didTapDoneButton()
    }

    func didTapDoneButton() {
        self.removeFromSuperview()
    }
}
