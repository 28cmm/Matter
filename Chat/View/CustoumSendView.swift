//
//  CustoumSendView.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-06-04.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class CustoumSendView: UIView {

    let textField = UITextField()
    let sendBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SEND", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        //button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    override var intrinsicContentSize: CGSize{
        return .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)
        autoresizingMask = .flexibleHeight
        
        textField.font = .systemFont(ofSize: 16)
        addSubview(textField)
        textField.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 5, left: 10, bottom: 5, right: 10))
        addSubview(sendBtn)
//        sendBtn.anchor(top: topAnchor, leading: textField.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: , left: 0, bottom: 0, right: 10), size: .init(width: <#T##CGFloat#>, height: <#T##CGFloat#>))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
