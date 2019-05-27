//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-07.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    var fullName : String?{
        didSet{
            checkFormValidity()
        }
    }
    var email : String?{
        didSet{
            checkFormValidity()
        }
    }
    var password : String?{
        didSet{
            checkFormValidity()
        }
    }
    var bindableImage = Bindable<UIImage>()
    //Reactive programming
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsReigistering = Bindable<Bool>()
    
    func performRegistration(compltion:@escaping (Error?)->()){
        guard let email = email, let password = password else {return}
        bindableIsReigistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err{
                
                compltion(err)
                return
            }
            self.saveImageToFireBase(completion: compltion)
            
    }
    }
    
    fileprivate func saveImageToFireBase(completion:@escaping (Error?)->()){
        let filename = UUID().uuid
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil
            , completion: { (_, err) in
                if let err = err{
                    completion(err)
                    return
                }
                print("Finished uploading image to storage")
                ref.downloadURL(completion: { (url, err) in
                    if let err = err{
                        completion(err)
                        return
                    }
                    self.bindableIsReigistering.value = false
                    print("Download url of our image is:", url?.absoluteString ?? "")
                    
                    self.saveInfoToFireStore(imageUrl: url?.absoluteString ?? "", completion: completion)
                    completion(nil)
                })
        })
    }
    
    fileprivate func saveInfoToFireStore(imageUrl: String, completion:@escaping (Error?)->()){
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData:[String:Any] = [
            "fullName":fullName ?? "",
            "uid":uid,
            "imageUrl1":imageUrl,
            "age": 18,
            "minSeekingAge": SettingVC.defaultMinSeekingAge,
            "maxSeekingAge": SettingVC.defaultMaxSeekingAge,
            "refresh":1
        ]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err{
                completion(err)
                return
            }
            
            completion(nil)
        }
    }
    
    func checkFormValidity(){
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
}
