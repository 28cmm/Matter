//
//  ViewController.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-03.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

extension HomeController: SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate, goMessageDelegate{
    
    func toMessage(cardUid: String, currentUser: User) {
        //dismiss(animated: true)
        self.chatUid = cardUid
        self.currentUser = currentUser
        print("this is oppppppppppppppppppppp , ", cardUid)
        goTest()
        
        
    }
    func goTest(){
        if MatchView.isMessage{
            MatchView.isMessage = false
            presentMessage { (chatArray) in
                self.chatUser(chatUid: self.chatUid, completion: { (usersss) in
//                    let controller = ChatTVC()
//                    controller.curUser = self.currentUser
//                    let navChatControl = UINavigationController(rootViewController: controller)
//
                    let innerController = ChatInnerTVC()
                    innerController.chatUser = ChatUser(chat: chatArray, user: usersss)
                    let navControl = UINavigationController(rootViewController: innerController)
                    self.present(navControl,animated:true)
                })
                
            }
        }
    }
    
    
    
    fileprivate func presentMessage(completion:@escaping ([Chat])->Void){
        
        
        Firestore.firestore().collection("chat").document(currentUser.uid!).collection("Message").document(chatUid).collection("Info").getDocuments { (snapShot, err) in
            if let err = err{
                return
            }
            var chatArray = [Chat]()
            snapShot?.documents.forEach({ (docData) in
                let data = docData.data()
                let chat = Chat(dictionary: data)
                chatArray.append(chat)
            })
            completion(chatArray)
        }
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
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
       
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        let userDEtailsController = UserDetailVC()
        userDEtailsController.cardViewModel = cardViewModel
        userDEtailsController.homeControl = self
        present(userDEtailsController, animated: true)
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    
}

class HomeController: UIViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topStackView.settingButton.addTarget(self, action: #selector(handleSetting), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        buttonStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        buttonStackView.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        buttonStackView.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        setupLayout()
        fetchCurrentUser()
        
        
    }
    //MatchView
    var currentUser:User!
    var chatUid:String!

     let topStackView = TopNavigationStackView()
     let cardDeckView = UIView()
     let buttonStackView = HomeBottomControlStackView()
    var cardViewModels = [CardViewModel]()

   
    
   
    @objc fileprivate func handleMessage(){
        let viewControl = ChatTVC()
        viewControl.curUser = user
        let navigation = UINavigationController(rootViewController: viewControl)
        present(navigation, animated: true)
    }
    
   
    
   
    fileprivate var user: User?
    fileprivate let hud = JGProgressHUD(style: .dark)
    
    fileprivate func fetchCurrentUser(){
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        guard let uid = Auth.auth().currentUser?.uid else{return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if err != nil{
                print("failed to fetch user," , err)
                self.hud.dismiss()
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            print(dictionary)
            self.user = User(dictionary: dictionary)
            self.fetchSwipes()
            self.fetchUserFireStore()
        }
        
    }
    var swipes = [String:Int]()
    
    fileprivate func fetchSwipes(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err{
                self.hud.textLabel.text = "OPPSSS"
                self.hud.detailTextLabel.text = err.localizedDescription
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2)
            }
            guard let data = snapshot?.data() as? [String:Int] else {return}
            self.swipes = data
        }
    }
    
    fileprivate func fetchUserFireStore(){
        let minAge = user?.minSeekingAge ?? 16
        let maxAge = user?.maxSeekingAge ?? 50
        
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThan: minAge).whereField("age", isLessThan: maxAge)
        topCardView = nil
        query.getDocuments { (snapshot, err) in
            self.hud.dismiss()
            if let err = err{
                print("failed to fetch",err)
                return
            }
            var previouseCardView: CardView?
            snapshot?.documents.forEach({ (documentSnapShot) in
                let userDictionary = documentSnapShot.data()
                let user = User(dictionary: userDictionary)
               let isSearch = user.uid != Auth.auth().currentUser?.uid
//                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                let hasNotSwipedBefore = true
                if isSearch && hasNotSwipedBefore{
                    let cardView = self.setUpCardFromUser(user: user)
                    previouseCardView?.nextCardView = cardView
                    previouseCardView = cardView
                    
                    if self.topCardView == nil{
                        self.topCardView = cardView
                    }
                }
                
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil{
            let registrationControll = RegistrationVC()
            registrationControll.delegate = self
            let navController = UINavigationController(rootViewController: registrationControll)
            present(navController,animated: true)
        }
        
    }
    var topCardView: CardView?
    @objc func handleDislike(){
        saveSwipeToFireStore(didLike: 0)
        swipeAnimation(translation: -500, angle: -15)
    }
    
    fileprivate func saveSwipeToFireStore(didLike:Int){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        guard let cardUID = topCardView?.cardViewModel.uid else {return}
        let documentData = [cardUID: didLike]
       
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err{
                print("fialed to fetch: ", err)
                return
            }
            if snapshot?.exists == true{
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData){(err) in
                    if let err = err{
                        print(err)
                        return
                    }
                    print("good")
                    if didLike == 1{
                        self.checkMatch(cardUID: cardUID)
                    }
                    
                }
            }else{
                Firestore.firestore().collection("swipes").document(uid).setData(
                documentData){(err) in
                    if let err = err{
                        print(err)
                        return
                    }
                    print("good")
                    if didLike == 1{
                        self.checkMatch(cardUID: cardUID)
                    }
                    
                }
            }
        }
    }
    
    fileprivate func checkMatch(cardUID:String){
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err{
                print("Failed to fetch document for card user:", err)
                return
            }
           // print(snapshot)
            guard let data = snapshot?.data() else {return}
           // print(data)
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let isMatched = data[uid] as? Int == 1
            if isMatched{
                print("Matched")
                self.presentMatchView(cardUID: cardUID)
            }
            
        }
    }
    fileprivate func presentMatchView(cardUID:String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        //Firestore.firestore()
        let ref = Firestore.firestore().collection("chat").document(uid)
        
       // .collection("Message").document(cardUID.collection("Info").document()
        let uselessData:[String:Any] = ["why do we need useless Data": "XX",
                                        "PleaseUpdateThisFirebase" : Timestamp()]
        ref.setData(uselessData)
        ref.collection("Message").document(cardUID).setData(uselessData)
        let refInfo = ref.collection("Message").document(cardUID).collection("Info").document()
        
        let documentData:[String:Any] = ["message" : "happy to connect!",
                                         "time": Timestamp(),
                                         "receiveUid": cardUID,
                                         "sendUid" : uid]
        refInfo.setData(documentData)
        
        //
        // guard let carDUid = cardUID. else {return}
        let ref2 = Firestore.firestore().collection("chat").document(cardUID)
        
        // .collection("Message").document(cardUID.collection("Info").document()
        ref2.setData(uselessData)
        ref2.collection("Message").document(uid).setData(uselessData)
        let refInfo2 = ref2.collection("Message").document(uid).collection("Info").document()
        let documentData2:[String:Any] = ["message" : "Nice to match!",
                                          "time": Timestamp(),
                                          "receiveUid": cardUID,
                                          "sendUid" : uid]
        refInfo2.setData(documentData2)
        
        let Mview = MatchView()
        Mview.currentUser = user
        Mview.cardUID = cardUID
        Mview.delegate = self
        
        view.addSubview(Mview)
        Mview.fillSuperview()
        
    }
    
    @objc func handleLike(){
        saveSwipeToFireStore(didLike: 1)
       swipeAnimation(translation: 700, angle: 15)
    }
    fileprivate func swipeAnimation(translation: CGFloat, angle: CGFloat) {
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = 0.5
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi/180
        rotationAnimation.duration = 0.5
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        CATransaction.commit()
    }
    @objc fileprivate func handleRefresh(){
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchCurrentUser()
    }
    var lastFetchedUser: User?
    fileprivate func setUpCardFromUser(user:User) -> CardView{
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    @objc func handleSetting(){
        let setVC = SettingVC()
        setVC.delegate = self
        let navControl = UINavigationController(rootViewController: setVC)
        present(navControl, animated: true)
        
    }
    // MARK:- Fileprivate
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews:[topStackView,cardDeckView,buttonStackView])
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        overallStackView.translatesAutoresizingMaskIntoConstraints = false
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardDeckView)
    }
}

