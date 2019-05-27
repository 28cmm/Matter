//
//  HomeBottomControlStackView.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-03.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class HomeBottomControlStackView: UIStackView {
    
    static func createButton(image:UIImage) -> UIButton{
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
     let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
     let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
     let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
     let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 75).isActive = true
        let subViews = [refreshButton,dislikeButton,superLikeButton,likeButton,specialButton]
        
        
        subViews.forEach { (v) in
            addArrangedSubview(v)
        }
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
