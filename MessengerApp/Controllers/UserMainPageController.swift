/*
    Main page that appear if user signed in.
 And disappear if user not signedvar.
*/

import Firebase
import FirebaseAuth
import Foundation
import UIKit
import AVFoundation

class UserMainPageController: UITableViewController, AVAudioPlayerDelegate {
  
    let cellId = "cellId"
    var soundPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SignOut", style: .plain, target: self, action: #selector(handleLogOut))
        
        let image = UIImage(named: "new-message")
        let menuBtn = UIButton(type: UIButton.ButtonType.infoLight)
    
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 0, height: 0)
        menuBtn.setImage(image, for: .normal)
        menuBtn.addTarget(self, action: #selector(handleNewMessage), for: UIControl.Event.touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 25).isActive = true
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 25).isActive = true
       
        
        self.navigationItem.rightBarButtonItem = menuBarItem
        
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
        
        observeMessages()
        print(messages.count)
        if Auth.auth().currentUser == nil{
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        }
        checkIfUserIsLoggedIn()
        
    }
    
    var messages = [Message]()
    func observeMessages(){
        Database.database().reference().child("messages").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                if dictionary["toID"] as? String == Auth.auth().currentUser?.uid{
                    let message = Message()
                    message.message = dictionary["message"] as? String
                    message.fromID = dictionary["fromID"] as? String
                    message.timestamp = dictionary["timestamp"] as? NSNumber
                    message.toID = dictionary["toID"] as? String
                    message.name = dictionary["name"] as? String
                    message.voiceMessage = dictionary["voiceMessage"] as? String
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    @objc func handleNewMessage(){
        
        let newMessageController = NewMessageController()
        newMessageController.sendMessageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    
    func showSendMessageController(user: User){
        let sendMessageController = SendMessageController(collectionViewLayout: UICollectionViewFlowLayout())
       
        sendMessageController.user = user
        navigationController?.pushViewController(sendMessageController, animated: true)
    }
    /*
     Sets bar title as user name.
     */
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        }else{
            fetchUserAndSetupTitle()
        }
        
        
    }
    
    
    func fetchUserAndSetupTitle(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
       
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                let user = User()
                user.email = dictionary["email"] as? String
                user.name = dictionary["name"] as? String
                user.userImageURL = dictionary["userImageURL"] as? String
                
                self.setupNavBarWithUser(user: user)
            }
        }
    }
    
    let titleView: UIView={
       let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        return view
    }()
    
    let userName:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userProfileImage:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    func setupNavBarWithUser(user: User){


        if let userProfileImageURL = user.userImageURL{
            userProfileImage.loadImageFromCacheWithURL(urlString: userProfileImageURL)
        }
       
        userName.text = user.name
        
        titleView.addSubview(userName)
        titleView.addSubview(userProfileImage)
        
       setupBarConstraints()
        
    }
    
    func setupBarConstraints(){
        
        
        userProfileImage.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        userProfileImage.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        userProfileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        userProfileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        userName.leftAnchor.constraint(equalTo: userProfileImage.rightAnchor, constant: 3).isActive = true
        userName.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        userName.heightAnchor.constraint(equalTo: userProfileImage.heightAnchor).isActive = true
        userName.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        self.navigationItem.titleView = titleView
    }
    
    @objc func handleLogOut(){
        do{
            try Auth.auth().signOut()
        }catch let signOutError{
            print(signOutError)
        }
        soundPlayer = AVPlayer()
        isPlaying = false
        onPause = false
        let viewController = LoginController()
        viewController.userMainPageController = self
        present(viewController, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    var playButtons = [UIButton]()
    var pauseButtons = [UIButton]()
    
    var isPlaying = false
    var onPause = false
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
//        cell.playMessageButton.tag = indexPath.row
//        cell.playMessageButton.addTarget(self, action: #selector(handlePlayAudio(_:)), for: .touchUpInside)
        
        if messages[indexPath.row].toID == Auth.auth().currentUser!.uid{
            let message = messages[indexPath.row]
            cell.message = message
        }
       
        cell.playButton.addTarget(self, action: #selector(handlePlayButton(_:)), for: .touchUpInside)
        cell.pauseButton.addTarget(self, action: #selector(handlePlayButton(_:)), for: .touchUpInside)
        cell.playButton.tag = indexPath.row
        cell.pauseButton.tag = indexPath.row
        let playButton = cell.playButton
        let pauseButton = cell.pauseButton
        playButtons.append(playButton)
        pauseButtons.append(pauseButton)
        
        return cell
    }
    
    @objc func handlePlayButton(_ sender: UIButton){
        senderButton = sender
        
        if sender.isHidden == false && sender != pauseButtons[sender.tag] && !isPlaying{
            
            if !onPause{
                if let stringURL = messages[sender.tag].voiceMessage, let url = URL(string: stringURL){
                    
                    let item = AVPlayerItem(url: url)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                    
                    soundPlayer = AVPlayer(playerItem: item)
                    
                    
                    }
                
            }
            soundPlayer.play()
            playButtons[sender.tag].isHidden = true
            pauseButtons[sender.tag].isHidden = false
            isPlaying = true
            onPause = false
            
        }else if isPlaying && !onPause{
                soundPlayer.pause()
                playButtons[sender.tag].isHidden = false
                pauseButtons[sender.tag].isHidden = true
                isPlaying = false
                onPause = true
        }
        
        
    }
    var senderButton = UIButton()
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButtons[senderButton.tag].isHidden = false
        pauseButtons[senderButton.tag].isHidden = true
        isPlaying = false
        onPause = false
    }
    
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
