import UIKit
import Firebase
/*
 Controller that show us list of users.
 */
class NewMessageController: UITableViewController {
    
    var users = [User]()
    let cellid = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Contacts"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleCancelButton))
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellid)
        
        fetchUser()
    }
    /*
     Returns us to previous View when taps.
     */
    @objc func handleCancelButton(){
        self.dismiss(animated: true, completion: nil)
    }
    /*
     Function that fetch all users from Firebase and adds their in our model - User class.
     */
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
               if snapshot.key != Auth.auth().currentUser?.uid {
                    let user = User()
                    user.id = snapshot.key
                    user.name = dictionary["name"] as? String
                    user.email = dictionary["email"] as? String
                    user.userImageURL = dictionary["userImageURL"] as? String
                    self.users.append(user)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! ContactCell
        cell.userNameTextField.text = users[indexPath.row].name
        cell.userEmailTextField.text = users[indexPath.row].email
        if let profileImageURL = users[indexPath.row].userImageURL{
            cell.profileImageView.loadImageFromCacheWithURL(urlString: profileImageURL)
        }
        cell.playButton.isHidden = true
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    var sendMessageController: UserMainPageController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.sendMessageController?.showSendMessageController(user: user)
            
            
        }
       
    }
    
}
