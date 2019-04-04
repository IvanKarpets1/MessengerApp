/*
 Controller component that implement ability authorezation/registration.
 That component has connection with UserMainPageController.
 */
/*
import needed stuff for correct controller work
 */
import UIKit
import Firebase
import FirebaseDatabase

class LoginController: UIViewController {
    var userMainPageController: UserMainPageController?
    /*
     User Interface interaction like buttons, fields, views...
     */
    
    lazy var profileImage:UIImageView={
       let imageView = UIImageView()
        imageView.image = UIImage(named: "profile-Image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImage)))
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    let inputsContainerView:UIView={
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        return v
    }()
    
    let userNameField:UITextField={
       let tf = UITextField()
       tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
        
    }()
    
    let userLoginField: UITextField={
        let tf = UITextField()
        tf.placeholder = "Login"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let userPasswordField: UITextField={
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let loginRegisterButton: UIButton={
        let b = UIButton()
        b.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        b.setTitleColor(.black, for: .normal)
        b.setTitle("Register", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 5
        b.layer.masksToBounds = true
        b.setTitleColor(UIColor.white, for: .normal)
        b.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return b
    }()
    
    let nameSeparatorView:UIView={
       let v = UIView()
        v.backgroundColor = UIColor(r:61,g:91,b:151)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let loginSeparatorView:UIView={
        let v = UIView()
        v.backgroundColor = UIColor(r:61,g:91,b:151)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let loginRegisterSegmentedControl:UISegmentedControl={
       let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 1
        sc.tintColor = UIColor.white
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    /*
     These vars have connection with field height. When user change Auth/Reg options , heights change.
     */
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var userNameFieldHeightAnchor: NSLayoutConstraint?
    var userLoginFieldHeightAnchor: NSLayoutConstraint?
    var userPasswordFieldHeightAnchor: NSLayoutConstraint?
    
    
    /*
     Func that change button title and fields heights.
     */
    @objc func handleLoginRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        inputsContainerViewHeightAnchor?.isActive = false
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        userNameFieldHeightAnchor?.isActive = false
        userNameFieldHeightAnchor = userNameField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        userNameFieldHeightAnchor?.isActive = true
        
        userLoginFieldHeightAnchor?.isActive = false
        userLoginFieldHeightAnchor = userLoginField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        userLoginFieldHeightAnchor?.isActive = true
        
        userPasswordFieldHeightAnchor?.isActive = false
        userPasswordFieldHeightAnchor = userPasswordField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        userPasswordFieldHeightAnchor?.isActive = true
        
    }
    /*
     Select Registration or Auth depend on user selected.
     */
    @objc func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            handleLogin()
        }else{
            handleRegister()
        }
            
        
    }
    /*
     Login handler. Auth.auth() has acces to Firebase API. And try to sign in.
     */
    func handleLogin(){
        guard let email = userLoginField.text, let password = userPasswordField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error as Any)
                return
            }
            
            self.userMainPageController?.fetchUserAndSetupTitle()
            self.userMainPageController?.messages = []
            self.userMainPageController?.observeMessages()
            self.userMainPageController?.tableView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    /*
     Handle Register.
     Auth.auth().createUser - creates user in Auth.
     Database.database().reference acces DataBase.
     usersReference.updateChildValues - creates new child with uid.
     
     */
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(r:61,g:91,b:151)
        
        /*
         Add subView for View like user inputs, buttons, views and other nedded stuff...
         */
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(profileImage)
        /*
         Changes button text.
         */
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            loginRegisterButton.titleLabel?.text = "Register"
        }else{
            loginRegisterButton.titleLabel?.text = "Login"
        }
       
        setupSegmentedControl()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImage()
        
        
    }
    
    func setupProfileImage(){
        profileImage.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -10).isActive = true
    profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    profileImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
    profileImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupSegmentedControl(){
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -10).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setupInputsContainerView(){
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(userNameField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(userLoginField)
        inputsContainerView.addSubview(loginSeparatorView)
        inputsContainerView.addSubview(userPasswordField)
        
        setupInputFields()
    }

    
    
    func setupInputFields(){
        userNameField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        userNameField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userNameFieldHeightAnchor = userNameField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        userNameFieldHeightAnchor?.isActive = true
        userNameField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        
        nameSeparatorView.topAnchor.constraint(equalTo: userNameField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        userLoginField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
        userLoginField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userLoginFieldHeightAnchor =  userLoginField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        userLoginFieldHeightAnchor?.isActive = true
        userLoginField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        
        loginSeparatorView.topAnchor.constraint(equalTo: userLoginField.bottomAnchor).isActive = true
        loginSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        userPasswordField.topAnchor.constraint(equalTo: loginSeparatorView.bottomAnchor).isActive = true
        userPasswordField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        userPasswordFieldHeightAnchor = userPasswordField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        userPasswordFieldHeightAnchor?.isActive = true
        userPasswordField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        
        
    }

    func setupLoginRegisterButton(){
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 14).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setupFieldConstraints(){
        
        
        userLoginField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        userLoginField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userLoginField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        userLoginField.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        userPasswordField.topAnchor.constraint(equalTo: userLoginField.bottomAnchor, constant: 10).isActive = true
        userPasswordField.heightAnchor.constraint(equalToConstant: 15).isActive = true
        userPasswordField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        userPasswordField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
       
    }

}

extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red: r/255,green: g/255, blue: b/255,alpha: 1)
    }
}

