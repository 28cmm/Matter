//
//  ChatUser.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-22.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatUser{
    var chat: [Chat]
    var user: User
    
    init(chat:[Chat]!, user:User!) {
        self.chat = chat
        self.user = user
    }
}
