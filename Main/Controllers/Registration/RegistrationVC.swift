
import Firebase
import UIKit
import JGProgressHUD
import FBSDKLoginKit

extension RegistrationVC{
	func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
		if let error = error{
			hud.textLabel.text = error.localizedDescription
			hud.show(in: view)
			hud.dismiss(afterDelay: 3, animated: true)
			return
		}
		let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
		Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
			if let error = error {
				self.hud.textLabel.text = error.localizedDescription
				self.hud.show(in: self.view)
				self.hud.dismiss(afterDelay: 3, animated: true)
				return
			}
			
			
				guard let user = Auth.auth().currentUser else {return}
			
				let docData:[String:Any] = [
					"fullName":user.displayName,
					"uid":user.uid,
					"imageUrl1":user.photoURL?.absoluteString,
					"age": 18,
					"minSeekingAge": SettingVC.defaultMinSeekingAge,
					"maxSeekingAge": SettingVC.defaultMaxSeekingAge,
					"refresh":1 ,
					"gg": 0
				]
			

			Firestore.firestore().collection("users").document(user.uid).setData(docData, completion: { (err) in
				if let err = err{
					print(err.localizedDescription)
				}
				self.dismiss(animated: true,completion: {
					self.delegate?.didFinishLoggingIn()
				})
			})
			}
		
	
	}
	
	func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
		} catch let signOutError as NSError {
			print ("Error signing out: %@", signOutError)
		}
		
	}
	
	
}


class RegistrationVC: UIViewController, LoginButtonDelegate{
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setUp()
		setUpTapGesture()
		setUpRegistrationObserver()
		faceBookBtn.delegate = self
		
	}
	
	var delegate: LoginControllerDelegate?
	
	let hud = JGProgressHUD(style: .dark)
	
    let selectPhotoBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(handleSelect), for: .touchUpInside)
		button.imageView?.contentMode = .scaleAspectFill
		button.clipsToBounds = true
        return button
    }()
	lazy var selectedPhotoHeightAnchor = selectPhotoBtn.heightAnchor.constraint(equalToConstant: 275)
	lazy var selectedPhotoWidthAnchor = selectPhotoBtn.widthAnchor.constraint(equalToConstant: 275)
	@objc fileprivate func handleSelect(){
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.allowsEditing = true
		present(imagePickerController, animated: true)
	}
    
    let fullNameTxtField: CustomTextField = {
        let textField = CustomTextField(padding: 24)
        textField.placeholder = "Enter full name"
        textField.backgroundColor = .white
		textField.addTarget(self, action:#selector(handleTextChange), for: .editingChanged)
		
		
        return textField
    }()
    let emailtextField: CustomTextField = {
        let textField = CustomTextField(padding: 24)
        textField.placeholder = "Enter email"
        
        textField.keyboardType = .emailAddress
        textField.backgroundColor = .white
		textField.addTarget(self, action:#selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    let passwordTxtField: CustomTextField = {
        let textField = CustomTextField(padding: 24)
        textField.placeholder = "Enter password"
       
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
		textField.addTarget(self, action:#selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    
    let registerBtn: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 25
		 button.backgroundColor = #colorLiteral(red: 0.6693089008, green: 0.666139245, blue: 0.6693861485, alpha: 1)
		button.isEnabled = false
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(.gray, for: .disabled)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
		button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
	
	let goToLoginButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Go to Login", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
		button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
		return button
	}()
	
	let faceBookBtn:FBLoginButton = {
		let btn = FBLoginButton()
		btn.permissions = ["email","public_profile"]
		btn.backgroundColor = .blue
		btn.layer.cornerRadius = 25
		return btn
	}()
	
	let registeringHUD = JGProgressHUD(style: .dark)
	@objc fileprivate func handleTextChange(textField: UITextField){
		
		if textField == fullNameTxtField{
			registrationViewModel.fullName = textField.text
		}else if textField == emailtextField{
			registrationViewModel.email = textField.text
			
		}else{
			registrationViewModel.password = textField.text
		}
	}
	let registrationViewModel = RegistrationViewModel()
	
	fileprivate func setUpRegistrationObserver(){
		registrationViewModel.bindableIsFormValid.bind { [unowned self](isValid) in
			if isValid!{
				self.registerBtn.isEnabled = true
				self.registerBtn.backgroundColor = #colorLiteral(red: 0.8132490516, green: 0.09731306881, blue: 0.3328936398, alpha: 1)
				self.registerBtn.setTitleColor(.white, for: .normal)
			}else{
				self.registerBtn.backgroundColor = .lightGray
				self.registerBtn.setTitleColor(.gray, for: .disabled)
			}
		}

		registrationViewModel.bindableImage.bind { [unowned self](img) in
			self.selectPhotoBtn.setImage(img?.withRenderingMode(.alwaysOriginal), for: .normal)
		}
		
		registrationViewModel.bindableIsReigistering.bind { [unowned self](isRegister) in
			if isRegister! == true{
				self.registeringHUD.textLabel.text = "Register"
				self.registeringHUD.show(in: self.view)
			}else{
				self.registeringHUD.dismiss()
			}
		}
	}
    let gradientLayer = CAGradientLayer()
	
	override func viewWillAppear(_ animated: Bool) {
		setUpNotificationObservers()
	}

    
    // MARK:- Private
    
    fileprivate func setUpTapGesture(){
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
	func setUpNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyvoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func handleKeyboardHide(notification:Notification){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func handleKeyvoardShow(notificaiton:Notification){
                guard let value = notificaiton.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardFrame = value.cgRectValue
        //print(keyboardFrame)
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        print(bottomSpace)
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference-8)
    }
    lazy var verticalStakView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [fullNameTxtField,emailtextField,passwordTxtField,registerBtn,faceBookBtn])
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoBtn,
        verticalStakView])
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact{
            overallStackView.axis = .horizontal
			verticalStakView.distribution = .fillEqually
			selectedPhotoWidthAnchor.isActive = true
			selectedPhotoHeightAnchor.isActive = false
        }else{
            overallStackView.axis = .vertical
			verticalStakView.distribution = .fill
			selectedPhotoWidthAnchor.isActive = false
			selectedPhotoHeightAnchor.isActive = true
        }
    }
	

	
	@objc fileprivate func handleGoToLogin(){
		let loginController = LoginController()
		loginController.delegate = delegate
		navigationController?.pushViewController(loginController, animated: true)
	}
    
    fileprivate func setUp(){
		
		navigationController?.isNavigationBarHidden = true
        gradientLayer.colors = [#colorLiteral(red: 0.9893690944, green: 0.3603764176, blue: 0.3745168447, alpha: 1).cgColor,#colorLiteral(red: 0.9005767703, green: 0.1322652996, blue: 0.4517819881, alpha: 1).cgColor]
        gradientLayer.frame = view.frame
        view.layer.addSublayer(gradientLayer)
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.spacing = 8
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor,padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		view.addSubview(goToLoginButton)
		goToLoginButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    

}
