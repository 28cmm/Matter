//
//  User.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-04.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

struct User: ProducesCardViewModel{
    var name: String?
    var age: Int?
    var profession: String?
//    let imageNames: [String]
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    let uid: String?
    
    var refresh: Int?
    
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    init(dictionary:[String:Any]) {
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
        self.refresh = dictionary["refresh"] as? Int
    }
    
    func toCardViewModel() -> CardViewModel{
        let attributeText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        let ageString = age != nil ? "\(age!)" : "N\\A"
        let professionString = (profession == nil) || (profession == "") ? "Not available" : "\(profession!)"
        attributeText.append(NSAttributedString(string: " \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        attributeText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font:UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        var imageUrls = [String]()
        if let url = imageUrl1 {imageUrls.append(url)}
        if let url = imageUrl2 {imageUrls.append(url)}
        if let url = imageUrl3 {imageUrls.append(url)}
        
        return CardViewModel(uid: self.uid ?? "", imageNames: imageUrls, attributedString: attributeText, textAligment: .left)
        
        
    }
}

