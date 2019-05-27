//
//  Chat.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-22.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Chat {
    var message:String?
    var receiveUid: String?
    var time: Timestamp?
    var sendUid: String?
    
    init(dictionary:[String:Any]) {
        self.message = dictionary["message"] as? String
        self.receiveUid = dictionary["receiveUid"] as? String
        self.time = dictionary["time"] as? Timestamp
        self.sendUid = dictionary["sendUid"] as? String
    }
    
}
