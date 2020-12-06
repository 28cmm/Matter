//
//  SwipePhotoPVC.swift
//  Tinder
//
//  Created by Yilei Huang on 2019-05-18.
//  Copyright © 2019 Joshua Fang. All rights reserved.
//

import UIKit

extension SwipePhotoPVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 {return nil}
        return controllers[index-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count-1 {return nil}
        return controllers[index + 1]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}){
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = barDeselectedColor})
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    
    
    
}

class SwipePhotoPVC: UIPageViewController {

    //var index = 0
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    var cardViewModel: CardViewModel!{
        didSet{
            controllers = cardViewModel.imageNames.map({ (imageUrl) -> UIViewController in
                let photoController = PhotoController(imageURL: imageUrl)
                return photoController
            })
            cardViewModel.imageNames.forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = self.barDeselectedColor
                barView.layer.cornerRadius = 2
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            setViewControllers([controllers.first!], direction: .forward, animated: true)
        }
        
    }
    
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    
    fileprivate func setupBarView(){
        view.addSubview(barsStackView)
       
        let paddingTop = isCardViewMode == false ? UIApplication.shared.statusBarFrame.height + 8 : 8
        barsStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
    }
    
    var controllers = [UIViewController()]
    
    fileprivate let isCardViewMode: Bool
    
    init(isCardViewMode: Bool = false){
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setupBarView()
       delegate = self
        if isCardViewMode{
            disableSwping()
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    @objc fileprivate func handleTap(tap:UITapGestureRecognizer){
        let currentControll = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentControll){
            barsStackView.arrangedSubviews.forEach({$0.backgroundColor = barDeselectedColor})
            if tap.location(in: self.view).x > view.frame.width/2{
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            }else{
                let previous = max(0, index - 1)
                let nextController = controllers[previous]
                setViewControllers([nextController], direction: .forward, animated: false)
                barsStackView.arrangedSubviews[previous].backgroundColor = .white
            }
            
        }
    }
    
    fileprivate func disableSwping(){
        view.subviews.forEach { (v) in
            if let v = v as? UIScrollView{
                v.isScrollEnabled = false
            }
        }
    }
}

class PhotoController: UIViewController{
    
     let imageView = UIImageView(image: #imageLiteral(resourceName: "lady4c"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    init(imageURL: String){
        if let url = URL(string: imageURL){
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
