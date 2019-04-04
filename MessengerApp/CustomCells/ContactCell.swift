import Foundation
import UIKit
import FirebaseDatabase

class ContactCell: UITableViewCell{
    
    var message: Message?{
        didSet{
            if let toID = message?.fromID{
                
                let ref = Database.database().reference().child("users").child(toID)
                ref.observe(.value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject]{
                        self.userNameTextField.text = dictionary["name"] as? String
                        self.userEmailTextField.text = self.message!.message
                        
                        if let profileImageURL = dictionary["userImageURL"] as? String{
                            self.profileImageView.loadImageFromCacheWithURL(urlString: profileImageURL)
                        }
                    }
                }, withCancel: nil)
            }
        }
    }
    
    var userNameTextField:UITextField = {
       var tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 12)
        return tf
    }()
    
    var userEmailTextField: UITextField = {
       var tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.systemFont(ofSize: 12)
        return tf
    }()
    
    var profileImageView: UIImageView = {
       var iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let playButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        pauseButton.isHidden = true
        addSubview(profileImageView)
        addSubview(userEmailTextField)
        addSubview(userNameTextField)
        addSubview(playButton)
        addSubview(pauseButton)
        setupConstraints()
    }
    
    func setupConstraints(){
    profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    userNameTextField.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 5).isActive = true
   // userNameTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
    userNameTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
    
    userEmailTextField.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 5).isActive = true
    //userEmailTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 3).isActive = true
    userEmailTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 10).isActive = true
        
    playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    playButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
    playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
    pauseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    pauseButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
    pauseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    pauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
