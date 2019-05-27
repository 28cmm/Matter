//
//  KeepSwipingBtn.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-19.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

class KeepSwipingBtn: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.9860600829, green: 0.1902240217, blue: 0.4316928387, alpha: 1)
        let rightColor = #colorLiteral(red: 0.9927075505, green: 0.4096614122, blue: 0.3155741096, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor,rightColor.cgColor]
        gradientLayer.locations = [0,1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let coronerRadius = rect.height/2
        let maskLayer = CAShapeLayer()
        let maskPath = CGMutablePath()
        maskPath.addPath(UIBezierPath(roundedRect: rect, cornerRadius: coronerRadius).cgPath)
        maskPath.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: coronerRadius).cgPath)
        maskLayer.path = maskPath
        maskLayer.fillRule = .evenOdd
        gradientLayer.mask = maskLayer
        
        
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = coronerRadius
        clipsToBounds = true
        gradientLayer.frame = rect
    }

}
