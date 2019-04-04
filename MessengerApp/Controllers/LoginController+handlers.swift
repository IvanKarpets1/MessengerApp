import UIKit
import Firebase
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleRegister(){
        guard let userLogin = userLoginField.text,let userName = userNameField.text, let userPassword = userPasswordField.text else{
            print("error")
            return
        }
        
        Auth.auth().createUser(withEmail: userLogin, password: userPassword) { (user, error) in
            if error != nil{
                let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let uid = user?.user.uid else{
                return
            }
            
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile-images").child("\(imageName).jpg")
            
            
            if let profileImage = self.profileImage.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1)  {
               
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error as Any)
                    }else{
                   
                        storageRef.downloadURL(completion: { (url, err) in
                        
                            if let userImageURL = url?.absoluteString {
                                
                                let values = ["name":userName,"email":userLogin,"userImageURL": userImageURL]
                                
                                self.handleUserRegisterIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                            }
  
                    })
                    }
                })
                   
                
    
            }
        }
    }
    
    func handleUserRegisterIntoDatabaseWithUID(uid: String, values: [String: AnyObject]){
        
        let ref = Database.database().reference(fromURL: "https://messengerapp-8f04c.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
        })
        self.userMainPageController?.fetchUserAndSetupTitle()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleProfileImage(){
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
        picker.delegate = self
        picker.allowsEditing = true
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}


