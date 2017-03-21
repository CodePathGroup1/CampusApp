//
//  RoundTextField.swift
//  CampusApp
//
//  Created by Thomas Zhu on 3/20/17.
//  Copyright © 2017 HLPostman. All rights reserved.
//

import UIKit

@IBDesignable
class RoundTextField: UITextField, UITextFieldDelegate {

    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15);
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 15.0
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        self.delegate = self
    }
    
    /* ====================================================================================================
     MARK: - Inset customization
     ====================================================================================================== */
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - Dismiss keyboard upon return key press
     ====================================================================================================== */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /* ==================================================================================================== */
}
