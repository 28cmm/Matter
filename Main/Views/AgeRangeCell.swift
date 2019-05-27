//
//  ageRangeCell.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-16.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit


class AgeRangeCell: UITableViewCell {
    
    let minSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 16
        return slider
    }()
    
    let maxSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 100
        slider.minimumValue = 16
        return slider
    }()
    
    let minLabel: UILabel = {
        let label = AgeRangeLabel()
        label.text = "Min"
        return label
    }()
    
    let maxLabel: UILabel = {
        let label = AgeRangeLabel()
        label.text = "Max"
        return label
    }()
    
    class AgeRangeLabel: UILabel{
        override var intrinsicContentSize: CGSize{
            return .init(width: 80, height: 0)
        }
    }
    
   
    
  

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let minSV = UIStackView(arrangedSubviews: [minLabel,minSlider])
       
        
        let maxSV = UIStackView(arrangedSubviews: [maxLabel,maxSlider])
        let overallStackView = UIStackView(arrangedSubviews: [minSV,maxSV])
        overallStackView.axis = .vertical
        overallStackView.spacing = 16
        addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
