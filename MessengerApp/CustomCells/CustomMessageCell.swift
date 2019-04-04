import Foundation
import UIKit

class CustomMessageCell: UITableViewCell {
    
    var textMessageField: UILabel={
       let tf = UILabel()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.numberOfLines = 0
        return tf
    }()
    
    var playMessageButton: UIButton={
        let btn = UIButton()
        btn.setTitle("Play", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8296319797, green: 0.4589558193, blue: 0.760106489, alpha: 1)
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews(){
       // addSubview(textMessageField)
       addSubview(playMessageButton)
        setupConstraints()
    }
    
   
    
    
    func setupConstraints(){
//       textMessageField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        textMessageField.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        textMessageField.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        textMessageField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playMessageButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playMessageButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        playMessageButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playMessageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
}
