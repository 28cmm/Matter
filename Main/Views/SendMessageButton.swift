//
//  SendMessageButton.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-19.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class SendMessageButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.9860600829, green: 0.1902240217, blue: 0.4316928387, alpha: 1)
        let rightColor = #colorLiteral(red: 0.9927075505, green: 0.4096614122, blue: 0.3155741096, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor,rightColor.cgColor]
        gradientLayer.locations = [0,1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = rect.height/2
        clipsToBounds = true
        gradientLayer.frame = rect
    }

}
