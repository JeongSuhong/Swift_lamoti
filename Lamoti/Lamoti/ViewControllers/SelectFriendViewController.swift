//
//  SelectFriendViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/10.
//

import UIKit
import Firebase

class SelectFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var array : [UserModel] = []
    var users = Dictionary<String,Bool>()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creatRoomButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("users").observe(DataEventType.value, with : { (snapshot) in
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                if (userModel.uid == myUid) {
                    continue
                }
                
                self.array.append(userModel)
            
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var view = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        view.nameText.text = array[indexPath.row].name
        view.profileImage.kf.setImage(with: URL(string: array[indexPath.row].profileImageUrl!))
//        view.checkbox.tag = indexPath.row
//        view.checkbox.delegate = self
        
        return view
    }
    
//    func didTap(_ checkbox: BEMCheckBox) {
//       if (checkbox.on) {
//           users[self.array[checkbox.tag].uid!] = true
//       } else {
//           users.removeValue(forKey: self.array[checkbox.tag].uid!)
//
//       }
//   }
    
     
    
    @IBAction func createRoom(_ sender: UIButton) {
        var myUid = Auth.auth().currentUser?.uid
        users[myUid!] = true
        let nsDic = users as! NSDictionary
        
        Database.database().reference().child("chatrooms").childByAutoId().child("users").setValue(nsDic)
    }

}

class SelectFriendCell : UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameText: UILabel!
}
