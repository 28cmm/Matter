//
//  SettingCell.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-14.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    class SettingTextField: UITextField {
        override var intrinsicContentSize: CGSize{
            return .init(width: 0, height: 44)
        }
        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 24, dy: 0)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 24, dy: 0)
        }
    }
    
    let textField: UITextField = {
        let tf = SettingTextField()
        tf.placeholder = "Enter Name"
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
        
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
        textField.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
