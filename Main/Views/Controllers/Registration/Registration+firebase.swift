//
//  Registration+firebase.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-08.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import Firebase

extension RegistrationVC{
    @objc  func handleRegister(){
        self.handleTap()
        registrationViewModel.bindableIsReigistering.value = true
        registrationViewModel.performRegistration { [weak self](err) in
            if let err = err{
                self?.showHUDWithError(err: err)
                return
            }
            self?.dismiss(animated: true, completion: {
                self?.delegate?.didFinishLoggingIn()
            })
            
        }
        
            
            
        
    }
    
    
    
    
}
