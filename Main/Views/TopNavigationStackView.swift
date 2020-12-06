//
//  TopNavigationStackView.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-03.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class TopNavigationStackView: UIStackView {

    let settingButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIButton(type: .system)
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        distribution = .equalCentering
        settingButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        fireImageView.setImage(#imageLiteral(resourceName: "app_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        
        let subViews = [settingButton,fireImageView,messageButton]
        subViews.forEach { (view) in
            addArrangedSubview(view)
        }
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)

        
        
        
       
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
