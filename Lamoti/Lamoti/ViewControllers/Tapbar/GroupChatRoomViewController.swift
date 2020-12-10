//
//  GroupChatRoomViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/10.
//

import UIKit
import Firebase

class GroupChatRoomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (datasnapshot) in
            let dic = datasnapshot.value as! [String:AnyObject]
            print(dic.count)
        }
    }

}
