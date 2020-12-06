//
//  ChatTVC.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-21.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

class ChatTVC: UITableViewController {

   
    var curUser:User!
    var chatUserArray = [ChatUser]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        tableView.backgroundView = UIView()
        tableView.backgroundColor = UIColor(white: 1, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
       downloadUser()
    }

    
    fileprivate func setUpNavigationItem(){
        navigationItem.title = "Matches"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(handleCancel))
        self.navigationController?.navigationBar.setupShadow(opacity: 0.8, radius: 4, offset: .init(width: 0, height: 10), color: UIColor.lightGray)
    
    }
    
    func createButton(){
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "Screen Shot 2019-05-25 at 12.44.18 PM").withRenderingMode(.alwaysOriginal), for: .normal)
        
    }
    @objc func handleCancel(){
        dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatUserArray.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatCell(style: .default, reuseIdentifier: nil)
        let index = chatUserArray[indexPath.row]
        cell.JobLabebl.text = index.user.profession
        cell.TopLabel.text = index.user.name
        guard let url = URL(string: index.user.imageUrl1 ?? "") else {return UITableViewCell()}
        cell.leftImageView.sd_setImage(with: url)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ChatInnerTVC()
        controller.chatUser = chatUserArray[indexPath.row]
        controller.chatUserIndex = indexPath.row
        let navContrl = UINavigationController(rootViewController: controller)
        present(navContrl,animated: true)
    }

// -- setUp --

        func downloadUser(){
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "loading"
        hud.show(in: view)
        self.fetchUser { (snapshot) in
            hud.dismiss()
            snapshot.documents.forEach({ (v) in
                print(v,"\n")
                let docId = v.documentID
                self.chatInfo(docId: docId, completion: { (chatArray) in
                    self.chatUser(chatUid: docId, completion: { (res) in
                        let chatUser = ChatUser(chat: chatArray, user: res)
                        self.chatUserArray.append(chatUser)
                        self.tableView.reloadData()
                    })
                })
            })
        }
    }
    
    
    fileprivate func fetchUser(completion: @escaping ( QuerySnapshot)->Void){
        let ref = Firestore.firestore().collection("chat").document("\(curUser.uid!)").collection("Message")
        ref.getDocuments{ (snapshot, err) in
            if err != nil{
                print("OOPPSS",err)
                return
            }
            completion(snapshot!)
        }
    }
    
    
    
    func chatInfo(docId:String, completion:@escaping ([Chat])->Void){
        let ref = Firestore.firestore().collection("chat").document("\(curUser.uid!)").collection("Message")
        ref.document(docId).collection("Info").order(by: "time", descending: false).getDocuments(completion: { (snapShot, err) in
            print(snapShot?.count)
            var chatArray = [Chat]()
            snapShot?.documents.forEach({ (doc) in
                let data = doc.data()
                chatArray.append(Chat(dictionary: data))
            })
            completion(chatArray)
        })
        
    }
    
    func chatUser(chatUid:String,completion:@escaping (User) -> Void){
        var user: User!
        Firestore.firestore().collection("users").document("\(chatUid)").getDocument { (snapShot, err) in
            if let err = err{
                print("there is err ", err)
                return
            }
            let data = snapShot?.data()
            user = User(dictionary: data!)
            completion(user)
        }
        
    }
  
}
