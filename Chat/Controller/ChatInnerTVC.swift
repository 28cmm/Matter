//
//  chatInnerTVC.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-23.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class ChatInnerTVC: UITableViewController {
    
    var chatUser: ChatUser!{
        didSet{
        }
    }
    var chatUserIndex:Int!
    let curUser = Auth.auth().currentUser
    lazy var inputTF: UITextField = {
        let textField = UITextField()
        textField.placeholder = chatUser.user.name
        return textField
    }()
    
    let sendBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SEND", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    let imageBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "picture").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 20).isActive = true
       // btn.clipsToBounds = true
        btn.imageView?.contentMode = .scaleAspectFit
      //  btn.clipsToBounds = true
        return btn
    }()
    let hud = JGProgressHUD(style: .dark)
    @objc fileprivate func handleSend(){

        guard let textMessage = inputTF.text, !textMessage.isEmpty else {return}
        saveData(textMessage: textMessage, receiveUid: chatUser.user.uid ?? "", sendUid:  curUser?.uid ?? "", forwho: chatUser.user.uid ?? "")
        saveData(textMessage: textMessage, receiveUid: chatUser.user.uid ?? "", sendUid: curUser?.uid ?? "", forwho:curUser!.uid)
        
    }
    
    var chatListener: ListenerRegistration!
    
    override func viewDidAppear(_ animated: Bool) {
        let curUser = Auth.auth().currentUser
        chatListener = Firestore.firestore().collection("chat").document(curUser!.uid).collection("Message").document(chatUser.user.uid!).collection("Info").order(by:"time" , descending: false).addSnapshotListener({ (snapShot, err) in
            if let err = err{
                debugPrint(err.localizedDescription)
                return
            }
            self.chatUser.chat = [Chat]()
            snapShot?.documents.forEach({ (docData) in
                let data = docData.data()
                let chat = Chat(dictionary: data)
                self.chatUser.chat.append(chat)
            })
            self.scrollToBottom()
            self.tableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        chatListener.remove()
    }
    fileprivate func saveData(textMessage: String, receiveUid:String, sendUid:String, forwho:String) {
        let docData:[String:Any] = ["message" : textMessage,
                                    "time": Timestamp(),
                                    "receiveUid": receiveUid,
                                    "sendUid" : sendUid]
        let whoReceive = forwho == receiveUid ? sendUid : receiveUid
        let ref = Firestore.firestore().collection("chat").document(forwho).collection("Message").document(whoReceive).collection("Info")
        hud.textLabel.text = "SENDING"
        hud.show(in: view)
        ref.addDocument(data: docData) { (err) in
            self.hud.dismiss()
            if let err = err{
                self.hud.textLabel.text = "Fail Sending"
                self.hud.detailTextLabel.text = "\(err.localizedDescription)"
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 4, animated: true)
                return
            }
            if forwho == self.curUser?.uid{
                self.inputTF.text = ""
                self.hud.textLabel.text = "Send Successful"
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 4, animated: true)
            }
        }
    }
    
    
    fileprivate let padding:CGFloat = 16

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpLayout()
        setUpNavigation()
        scrollToBottom()
        setUpGesture()
    }
    func setUpGesture(){
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    @objc fileprivate func handleTap(tap:UITapGestureRecognizer){
        tableView.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    fileprivate func setUpObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyvoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc fileprivate func handleKeyvoardShow(notificaiton:Notification){
        guard let value = notificaiton.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = value.cgRectValue
        //print(keyboardFrame)
        let bottomSpace = view.frame.height - stackView.frame.height
        print(bottomSpace)
        let difference = keyboardFrame.height - stackView.frame.height
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference-8)
    }
    @objc func handleKeyboardHide(notification:Notification){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    fileprivate func setupTableView(){
        tableView.backgroundView = UIView()
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = #colorLiteral(red: 0.952085793, green: 0.9528070092, blue: 0.9521974921, alpha: 1)
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
        tableView.alwaysBounceVertical = true
        
       
    }
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatUser.chat.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    lazy var stackView = UIStackView(arrangedSubviews: [inputTF,imageBtn,sendBtn])
    
    func setUpLayout(){
        inputTF.widthAnchor.constraint(equalToConstant: 250).isActive = true
        view.addSubview(stackView)
        stackView.spacing = padding
        stackView.setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)
        
//        stackView.addBackground(color: .red)
        stackView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,padding: .init(top: padding, left: padding, bottom: 0, right: padding))
        stackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    fileprivate func setUpNavigation(){
        navigationItem.title = chatUser.user.name!
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Matches", style: .plain, target: self, action: #selector(handleBack))
        
        self.navigationController?.navigationBar.setupShadow(opacity: 0.8, radius: 4, offset: .init(width: 0, height: 10), color: UIColor.lightGray)
//
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    @objc fileprivate func handleBack(){
        dismiss(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = InnerChatCell(style: .default, reuseIdentifier: nil)
        let chat = chatUser.chat[indexPath.row]
        cell.layoutIfNeeded()
        print("chat uid is \(chat.sendUid) and cur uid is \(curUser?.uid)")
        if chat.sendUid == curUser?.uid{
            print("true")
            cell.isRight = false
            cell.messageIabel.text = chat.message
        }else{
            print("false")
            cell.isRight = true
            cell.messageIabel.text = chat.message
        }
        cell.backgroundColor = #colorLiteral(red: 0.952085793, green: 0.9528070092, blue: 0.9521974921, alpha: 1)
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatUser.chat.count
    }


}
