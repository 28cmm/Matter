//
//  Bindable.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-07.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
    
}
