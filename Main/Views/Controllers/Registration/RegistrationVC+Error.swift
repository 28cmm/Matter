//
//  RegistrationVC+Error.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-07.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import JGProgressHUD

extension RegistrationVC{
    func showHUDWithError(err:Error){
        registeringHUD.dismiss(animated: true)
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "failed registration"
        hud.detailTextLabel.text = err.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
    }
}
