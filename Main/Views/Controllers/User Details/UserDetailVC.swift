//
//  UserDetailVC.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-17.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

extension UserDetailVC: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        print(changeY)
        let imageView = swipingPhotosController.view!
        imageView.frame = CGRect(x: min(0,-changeY), y: min(0,-changeY), width: width, height:  width+extraHeight)
    }
}

class UserDetailVC: UIViewController{
    
    var homeControl: HomeController!
    var cardViewModel : CardViewModel! {
        didSet{
            infoLabel.attributedText = cardViewModel.attributedString
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return button
    }()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User name some bbio text down below"
        label.numberOfLines = 0
        return label
    }()
    
    let swipingPhotosController = SwipePhotoPVC()
    
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDisLike))
    lazy var superLikeBtn = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDisLike))
    lazy var likeBtn = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleLike))
    
    @objc fileprivate func handleDisLike(){
       homeControl.handleDislike()
        self.handleTapDismiss()
    }
    @objc fileprivate func handleLike(){
        homeControl.handleLike()
        self.handleTapDismiss()
    }

    fileprivate func createButton(image: UIImage, selector: Selector)->UIButton{
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        setUpVisualBlurEffectView()
        setupBottomControls()
    }
    
    fileprivate func setupBottomControls(){
        let stackView = UIStackView(arrangedSubviews: [dislikeButton,superLikeBtn,likeBtn])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0),size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setUpVisualBlurEffectView(){
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setUpLayout() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let swipingView = swipingPhotosController.view!
        scrollView.addSubview(swipingView)
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor,padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding:.init(top: -25, left: 0, bottom: 0, right: 25),size: .init(width: 50, height: 50))
    }
    fileprivate let extraHeight: CGFloat = 80
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraHeight)
    }
    
    
    @objc fileprivate func handleTapDismiss(){
        self.dismiss(animated: true)
    }
    

}
