import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import AVFoundation
import FirebaseStorage
/*
 Class that implements send messages.
 */
class SendMessageController: UICollectionViewController, UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var fileName = "audioFile.m4a"
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
        }
    }
    let inputContainerView:UIView={
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    let sendTextMessageButton:UIButton={
        let b = UIButton(type: UIButton.ButtonType.system)
        b.setImage(UIImage(named: "send-message"), for: UIControl.State.normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleSendTextMessage), for: .touchUpInside)
        return b
    }()
    
    let sendVoiceMessageButton:UIButton={
        let b = UIButton(type: UIButton.ButtonType.system)
        b.setImage(UIImage(named: "microphone"), for: UIControl.State.normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(record), for: .touchUpInside)
       
        return b
    }()
    
    let sendTextMessageView:UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    let sendVoiceMessageView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var inputTextField:UITextField={
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "write message..."
        tf.text = ""
        tf.addTarget(self, action: #selector(handleChangeIcon), for: .editingChanged)
        tf.delegate = self
        return tf
    }()
    
    let separatorView: UIView={
        let v = UIView()
        v.backgroundColor = UIColor.black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        setupConststraints()
        self.sendTextMessageView.alpha = 0
        self.sendVoiceMessageView.alpha = 1
        
        setupRecorder()
       
    }
    
    func setupRecorder(){
        
        let recordSetings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.0
            ] as [String : Any]
        
        do{
            soundRecorder = try AVAudioRecorder(url: getFileURL() as URL, settings: recordSetings)
            
        }
        catch{
            if let err = error as Error?{
                print(err.localizedDescription)
            }else{
                soundRecorder.delegate = self
                soundRecorder.prepareToRecord()
            }
        }
        
    }
    
    func getCacheDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
   
    func getFileURL() -> NSURL{
        let path = getCacheDirectory().appending(fileName)
        let filePath = NSURL(fileURLWithPath: path)
        return filePath
    }
    
  
    
    var recordButton:UIButton={
       var btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("Record", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(record), for: .touchUpInside)
        return btn
    }()
    
    var isRecorded = false
    @objc func record(){
        if !isRecorded{
            soundRecorder.record()
            sendVoiceMessageButton.backgroundColor = #colorLiteral(red: 0.4862353667, green: 0.4904139009, blue: 0.5, alpha: 1)
           isRecorded = true
        }else{
            soundRecorder.stop()
            sendVoiceMessageButton.backgroundColor = .clear
            isRecorded = false
            handleSendTextMessage()
        }
    }
    
   
    
    func preparePlayer(){
        do{
            soundPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        }catch{
            if let err = error as Error?{
                print(err.localizedDescription)
            }else{
                soundPlayer.delegate = self
                soundPlayer.prepareToPlay()
                soundPlayer.volume = 3.0
            }
        }
    }
    
    @objc func handleChangeIcon(){
        
        if let charactersCount = inputTextField.text?.count, charactersCount > 0{
            UIView.animate(withDuration: 0.2, animations: {
                self.sendTextMessageView.alpha = 1
                self.sendVoiceMessageView.alpha = 0
            }, completion: nil)
            
        }else{
            UIView.animate(withDuration: 0.2, animations: {
                self.sendTextMessageView.alpha = 0
                self.sendVoiceMessageView.alpha = 1
            }, completion: nil)
        }
    }
    
    /*
     Database.database().reference().child - access to DB.
     childRef.updateChildValues - adds new message.
     */
    
    @objc func handleSendTextMessage(){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID = user!.id
        let fromID = Auth.auth().currentUser!.uid
        
        do{
           
            let uploadedAudioMesaageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("voice-messages").child("\(uploadedAudioMesaageName).m4a")
           
            storageRef.putFile(from: getFileURL() as URL, metadata: nil) { (metadata, error) in
                if error != nil{
                    print(error as Any)
                }else{
                    
                    storageRef.downloadURL(completion: { (url, err) in
                        
                        if let voiceMessageURL = url?.absoluteString{
                            let timestamp = Int(NSDate().timeIntervalSince1970)
                            
                            
       Database.database().reference().child("users").child(fromID).observe(.value, with: { (snapshot) in
                                if let dictionary = snapshot.value as? [String:AnyObject]{
                                    let name = dictionary["name"]
                                    
                                    let values = ["message": self.inputTextField.text!,"voiceMessage": voiceMessageURL, "name": name!, "fromID": fromID, "toID": toID!, "timestamp": timestamp] as [String : Any]
                                    childRef.updateChildValues(values)
                                    
                                    self.inputTextField.text = ""
                                }
                            })
  
                        }
                        
                    })
                }
            }
            
        }
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendTextMessage()
        return true
    }
    
    func setupConststraints(){
        view.addSubview(inputContainerView)
        view.addSubview(separatorView)
        
        
        sendTextMessageView.addSubview(sendTextMessageButton)
        sendVoiceMessageView.addSubview(sendVoiceMessageButton)
        
        inputContainerView.addSubview(inputTextField)
        inputContainerView.addSubview(sendTextMessageView)
        inputContainerView.addSubview(sendVoiceMessageView)
        
        inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        separatorView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        inputTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 5).isActive = true
        inputTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor, constant: -50).isActive = true
    
        
        sendTextMessageView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        sendTextMessageView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor).isActive = true
        sendTextMessageView.leftAnchor.constraint(equalTo: inputTextField.rightAnchor).isActive = true
        sendTextMessageView.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true

        
        sendVoiceMessageView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        sendVoiceMessageView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor).isActive = true
        sendVoiceMessageView.leftAnchor.constraint(equalTo: inputTextField.rightAnchor).isActive = true
        sendVoiceMessageView.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true

        sendVoiceMessageButton.topAnchor.constraint(equalTo: sendVoiceMessageView.topAnchor, constant: 10).isActive = true
        sendVoiceMessageButton.leftAnchor.constraint(equalTo: sendVoiceMessageView.leftAnchor, constant: 10).isActive = true
        sendVoiceMessageButton.rightAnchor.constraint(equalTo: sendVoiceMessageView.rightAnchor, constant: -10).isActive = true
        sendVoiceMessageButton.bottomAnchor.constraint(equalTo: sendVoiceMessageView.bottomAnchor, constant: -10).isActive = true


        
        sendTextMessageButton.topAnchor.constraint(equalTo: sendTextMessageView.topAnchor, constant: 10).isActive = true
        sendTextMessageButton.leftAnchor.constraint(equalTo: sendTextMessageView.leftAnchor, constant: 10).isActive = true
        sendTextMessageButton.rightAnchor.constraint(equalTo: sendTextMessageView.rightAnchor, constant: -10).isActive = true
        sendTextMessageButton.bottomAnchor.constraint(equalTo: sendTextMessageView.bottomAnchor, constant: -10).isActive = true
        
      
       
        
    }
}
