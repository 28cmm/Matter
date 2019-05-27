//
//  CustoumTextField.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-07.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    var padding:CGFloat
    //var height: CGFloat
    init(padding:CGFloat){
        self.padding = padding
        //self.height = height
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 25
        
        
    }
    
    
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    override var intrinsicContentSize: CGSize{
        return .init(width: 0, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
