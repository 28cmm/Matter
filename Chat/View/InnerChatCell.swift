//
//  InnerChatCell.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-23.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class UILabelPadding: UILabel {
    
    let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: heigth)
    }
    
    
    
}

class InnerChatCell: UITableViewCell {

    var isRight:Bool!{
        didSet{
            setUpLayout()
        }
    }
     let messageIabel: UILabel = {
        let label = UILabelPadding()
        label.numberOfLines = 0
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true

        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       // setUpLayout()
    }
    fileprivate let padding:CGFloat = 16
    
    fileprivate func setUpLayout(){
        print("gg")
        addSubview(messageIabel)
        messageIabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        messageIabel.preferredMaxLayoutWidth = 200
        if isRight == true{
            messageIabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: padding, left: padding, bottom: padding, right: padding * 5))
            messageIabel.textColor = .black
            messageIabel.backgroundColor = #colorLiteral(red: 0.9996390939, green: 1, blue: 0.9997561574, alpha: 1)
            
            
         //  messageIabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7)
        }else{
            messageIabel.anchor(top: topAnchor, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor,padding: .init(top: padding, left: padding * 5, bottom: padding, right: padding))
         //  messageIabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7)
            messageIabel.textColor = .black
            messageIabel.backgroundColor = #colorLiteral(red: 0.6277691126, green: 0.905141294, blue: 0.3533426523, alpha: 1)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
