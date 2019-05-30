//
//  Registration+ImageExtension.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-07.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

extension RegistrationVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image : UIImage!
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            image = img
        }
        else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            image = img
        }
        registrationViewModel.bindableImage.value = image
        registrationViewModel.checkFormValidity()
        
        dismiss(animated: true, completion: nil)
    }
}
