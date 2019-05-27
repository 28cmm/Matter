//
//  CardViewModel.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-04.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}


//view model us supposed represent the state of our view

class CardViewModel {
    let uid: String
    let imageNames: [String]
    let attributedString: NSAttributedString
    let textAligment: NSTextAlignment
    
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAligment: NSTextAlignment) {
        self.imageNames = imageNames
        self.attributedString = attributedString
        self.textAligment = textAligment
        self.uid = uid
        
    }
    
    fileprivate var imageIndex = 0{
        didSet{
            let imageUrl = imageNames[imageIndex]
            
            imageIndexObserver?(imageIndex,imageUrl)
        }
    }
    
    
    //Reactive Programming
    var imageIndexObserver:((Int,String?)->())?
    
    func advanceToNextPhoto(){
        imageIndex = min(imageIndex + 1, imageNames.count-1)
        
    }
    
    func goToPreviousPhoto(){
        imageIndex = max(0,imageIndex-1)
    }
}


