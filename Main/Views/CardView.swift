//
//  CardView.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-03.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}

class CardView: UIView {
    
    var nextCardView: CardView?
    
    var delegate: CardViewDelegate?
    
    var cardViewModel: CardViewModel!{
        didSet{
            swipingPhotosController.cardViewModel = self.cardViewModel

            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAligment
            
            (0..<cardViewModel.imageNames.count).forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                brasStackView.addArrangedSubview(barView)
            }
            brasStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setUpImageIndexObserver()
            
        }
    }
    
    fileprivate func setUpImageIndexObserver(){
        cardViewModel.imageIndexObserver = { [weak self](idx,image) in
           
            self?.brasStackView.arrangedSubviews.forEach({ (v) in
                v.backgroundColor = self?.barDeselectedColor
            })
            self?.brasStackView.arrangedSubviews[idx].backgroundColor = .white
            
        }
    }
    //encapsulation
//    fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
    fileprivate let swipingPhotosController = SwipePhotoPVC(isCardViewMode: true)
//    lazy var imageView = swipingPhotosController.view!
    fileprivate let informationLabel = UILabel()
    fileprivate let brasStackView = UIStackView()
    let gradientLayer = CAGradientLayer()
    
    fileprivate let threshold: CGFloat = 100
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
   
    fileprivate let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleMoreInfo(){
        
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    
    
    fileprivate func setUpLayout() {
        //custoum drawing code
        layer.cornerRadius = 10
        clipsToBounds = true
        let swipingPhotosControl = swipingPhotosController.view!
       
        swipingPhotosControl.contentMode = .scaleAspectFill
        addSubview(swipingPhotosControl)
        swipingPhotosControl.fillSuperview()
        
//        setupBarsStackView()
        //add a gradient layer
        setUpGradientLayer()
        
        addSubview(informationLabel)
        
        informationLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 0))
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    fileprivate func setupBarsStackView(){
        addSubview(brasStackView)
        brasStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8),size: .init(width: 0, height: 4))
        brasStackView.spacing = 4
        brasStackView.distribution = .fillEqually
     
    }
    fileprivate func setUpGradientLayer(){
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5,1.1]
        
        layer.addSublayer(gradientLayer)
    }
    override func layoutSubviews() {
        gradientLayer.frame = self.frame
    }
    
    //Tap Gesture
    
    var imageIndex = 0
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer){
        let tapLocation = gesture.location(in: nil)
        let shouldAdvance = tapLocation.x > frame.width/2 ? true : false
        if shouldAdvance{
            cardViewModel.advanceToNextPhoto()
        }else{
            cardViewModel.goToPreviousPhoto()
        }
    }
    
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer){
        
        switch gesture.state {
        case.began:
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            ()
        }
       
        
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        //rotation
        let translation = gesture.translation(in: nil)
        let degree: CGFloat = translation.x / 20
        let angle = degree * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection:CGFloat = gesture.translation(in: nil).x > 0 ? 1: -1
        let shouldDismmiedd = abs(gesture.translation(in: nil).x) > threshold
        
        guard let homeController = self.delegate as? HomeController else {return}
        if shouldDismmiedd{
            if translationDirection == 1{
                homeController.handleLike()
            }else{
                homeController.handleDislike()
            }
        }else{
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
