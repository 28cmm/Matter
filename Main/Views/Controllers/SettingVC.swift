//
//  SettingVC.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-13.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage
import FBSDKLoginKit

protocol SettingsControllerDelegate {
    func didSaveSettings()
}
class HeaderLabel: UILabel{
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}

class CustoumImagePickerController: UIImagePickerController{
    var imageButton: UIButton?
}

extension SettingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        
        let imageButton = (picker as? CustoumImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else{ return }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "uploading image ..."
        hud.show(in: self.view)
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            
            if let err = err{
                hud.dismiss()
                print("failed to upload image", err)
                return
            }
            ref.downloadURL(completion: { (url, err) in
                hud.dismiss()
                if let err = err{
                    print("failed to retrieve dowload URL:", err)
                }
                print(url?.absoluteString ?? "")
                if imageButton == self.image1Button{
                    self.user?.imageUrl1 = url?.absoluteString
                }else if imageButton == self.image2Button{
                    self.user?.imageUrl2 = url?.absoluteString
                }else if imageButton == self.image3Button{
                    self.user?.imageUrl3 = url?.absoluteString
                }
                
            })
        }
    }
}

class SettingVC: UITableViewController {
    
    var delegate: SettingsControllerDelegate?
    
    lazy var image1Button = createButton(selector:#selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector:#selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector:#selector(handleSelectPhoto))
    
    func createButton(selector:Selector) -> UIButton{
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }
    
    @objc fileprivate func handleSelectPhoto(button: UIButton){
        let imagePicker = CustoumImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker,animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        tableView.backgroundView = UIView()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        fetchCurrentUser()
        
    }
    var user: User?
    
    fileprivate func fetchCurrentUser(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if err != nil{
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            print(dictionary)
            self.user = User(dictionary: dictionary)
            self.loadUserPhotos()
            
            self.tableView.reloadData()
        }
    }
    
    fileprivate func loadUserPhotos(){
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
       
        
    }
    
    
    
    fileprivate func setUpNavigationItem(){
        navigationItem.title = "Setting"
        //navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 21)]
        //navigationController?.navigationBar.tintColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
            
        ]
    }
    
    @objc fileprivate func handleSave(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData : [String:Any] = [
            "uid": uid,
            "fullName" : user?.name ?? "",
            "imageUrl1" : user?.imageUrl1 ?? "",
            "imageUrl2" : user?.imageUrl2 ?? "",
            "imageUrl3" : user?.imageUrl3 ?? "",
            "age" : user?.age ?? -1,
            "profession" : user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1,
            "maxSeekingAge" : user?.maxSeekingAge ?? -1,
            "refresh": user?.refresh ?? 1
        ]
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: self.view)
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err{
                print(err)
                return
            }
            hud.dismiss()
            self.dismiss(animated: true,completion: {
                self.delegate?.didSaveSettings()
            })
        }
    }
    
    @objc fileprivate func handleLogout(){
       try? Auth.auth().signOut()
        LoginManager().logOut()
        dismiss(animated: true)
        
       
    }
    
    
    lazy var header: UIView = {
        let header = UIView()
        
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        
        let stackView = UIStackView(arrangedSubviews: [image2Button,image3Button])
        stackView.axis = .vertical
        stackView.spacing = padding
        stackView.distribution = .fillEqually
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return header
        }
        let headerLabel = HeaderLabel()
        switch section{
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return headerLabel
       
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    @objc fileprivate func handleSlider(slider: UISlider){
        print(slider.value)
        
        let indexPath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexPath) as? AgeRangeCell
       // ageRangeCell?.minSlider
        if slider == ageRangeCell?.minSlider{
            if slider.value > ageRangeCell?.maxSlider.value ?? 0 {
                ageRangeCell?.maxSlider.value = ageRangeCell?.minSlider.value ?? 0
                ageRangeCell?.maxLabel.text = "Max \(Int(slider.value))"
                self.user?.maxSeekingAge = Int(slider.value)
            }
            ageRangeCell?.minLabel.text = "Min \(Int(ageRangeCell?.minSlider.value ?? 0))"
            self.user?.minSeekingAge = Int(slider.value)
        }else if slider == ageRangeCell?.maxSlider{
            if slider.value < ageRangeCell?.minSlider.value ?? 0 {
                ageRangeCell?.minSlider.value = ageRangeCell?.maxSlider.value ?? 0
                ageRangeCell?.minLabel.text = "Min \(Int(slider.value))"
                self.user?.minSeekingAge = Int(slider.value)
            }
            ageRangeCell?.maxLabel.text = "Max \(Int(slider.value))"
            self.user?.maxSeekingAge = Int(slider.value)
        }
        
    }
    static let defaultMinSeekingAge = 16
    static let defaultMaxSeekingAge = 50
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingCell(style: .default, reuseIdentifier: nil)
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.maxSlider.addTarget(self, action: #selector (handleSlider), for: .valueChanged)
            ageRangeCell.minSlider.addTarget(self, action: #selector (handleSlider), for: .valueChanged)
            
            ageRangeCell.minLabel.text = "Min \(user?.minSeekingAge ?? SettingVC.defaultMinSeekingAge)"
            ageRangeCell.maxLabel.text = "Max \(user?.maxSeekingAge ?? SettingVC.defaultMaxSeekingAge)"
            ageRangeCell.maxSlider.value = Float(user?.maxSeekingAge ?? SettingVC.defaultMaxSeekingAge)
            ageRangeCell.minSlider.value = Float(user?.minSeekingAge ?? SettingVC.defaultMinSeekingAge)
            
            return ageRangeCell
        }
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = self.user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = self.user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Enter Age"
            if let age = self.user?.age{
                cell.textField.text = String(age)
                cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
            }
        default:
            cell.textField.placeholder = "Enter Bio"
           
            
        }
        
        return cell
    }
    
    @objc fileprivate func handleNameChange(textFiled: UITextField){
        print("Name Changing: \(textFiled.text ?? "")")
        self.user?.name = textFiled.text
    }
    @objc fileprivate func handleProfessionChange(textFiled: UITextField){
        self.user?.profession = textFiled.text ?? ""
    }
    @objc fileprivate func handleAgeChange(textFiled: UITextField){
        self.user?.age = Int(textFiled.text ?? "")
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
             return 300
        }
        return 40
       
    }
    
    @objc fileprivate func handleCancel(){
        dismiss(animated: true)
    }
    

   

}


