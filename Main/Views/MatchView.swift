//
//  MatchView.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-19.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import Firebase


protocol goMessageDelegate{
    func toMessage(cardUid:String,currentUser:User)
}



class MatchView: UIView {
    
    var currentUser: User!{
        didSet{
        }
    }
    
    var delegate:goMessageDelegate!
    
   static var isMessage = false
    
    var cardUID : String!{
        didSet{
            Firestore.firestore().collection("users").document(cardUID).getDocument { (snapshot, err) in
                guard let dictionary = snapshot?.data() else {return}
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else {return}
                 self.cardUserImageView.sd_setImage(with: url)
                
                self.descirptionLabel.text = "You and \(user.name ?? "") have liked\n each other"
                guard let currentUrl = URL(string: self.currentUser.imageUrl1 ?? "") else{return}
                self.currentUserImageView.sd_setImage(with: currentUrl, completed: { (_, _, _, _) in
                    self.setUpAnimation()
                })
            }
        }
    }
    
    fileprivate let itsAMacthImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "331558320760_.pic_hd"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    fileprivate let descirptionLabel: UILabel = {
        let label = UILabel()
        label.text = "You and x have liked\n each other"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    
    fileprivate let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly3"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    fileprivate let cardUserImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "kelly3"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.alpha = 0
        return imageView
    }()
    
    fileprivate let sendButton: UIButton = {
        //let button = SendMessageButton(type: .system)
        let button = SendMessageButton(type: .system)
        button.setTitle("SEND MESSAGE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleSend(){
        MatchView.isMessage = true
        delegate?.toMessage(cardUid: cardUID,currentUser: currentUser!)
        self.removeFromSuperview()
    }
    
    fileprivate let keepSwipingBtn: UIButton = {
        let button = KeepSwipingBtn(type: .system)
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleTap) , for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBlurView()
        setupLayout()
        
        
    }
    fileprivate func setUpAnimation(){
            //starting positions
        views.forEach({$0.alpha = 1})
        let angle = 30 * CGFloat.pi / 180
        currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        
        cardUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        
        sendButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingBtn.transform = CGAffineTransform(translationX: 500, y: 0)
        
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
            //animation 1-translation
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45, animations: {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
            })
            
            
            //animation2 - rotation
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
                
             
            })
        }) { (_) in
            
        }
        
        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.sendButton.transform = .identity
            self.keepSwipingBtn.transform = .identity
        })
    }
    lazy var views = [
        itsAMacthImageView,
        descirptionLabel,
        currentUserImageView,
        cardUserImageView,
        sendButton,
        keepSwipingBtn
    ]
    
    fileprivate func setupLayout(){
        views.forEach { (v) in
            addSubview(v)
            v.alpha = 0
        }
        itsAMacthImageView.anchor(top: nil, leading: nil, bottom: descirptionLabel.topAnchor, trailing: nil,padding: .init(top: 0, left: 0, bottom: 16, right: 0),size: .init(width: 300, height: 80))
        itsAMacthImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        
        descirptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0),size: .init(width: 0, height: 50))
        
       
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: 140, height: 140))
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        currentUserImageView.layer.cornerRadius = 140/2
        
        
        
        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil,padding: .init(top: 0, left: 16, bottom: 0, right: 0),size: .init(width: 140, height: 140))
        cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cardUserImageView.layer.cornerRadius = 140/2
        
        addSubview(sendButton)
        sendButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 32, left: 48, bottom: 0, right: 48),size: .init(width: 0, height: 60))
        
        addSubview(keepSwipingBtn)
        keepSwipingBtn.anchor(top: sendButton.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor,padding: .init(top: 32, left: 48, bottom: 0, right: 48),size: .init(width: 0, height: 60))
    }
    
    fileprivate func setupBlurView(){
        
        
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        }) { (_) in
            
        }
    }
    
    @objc func handleTap(Tap:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
