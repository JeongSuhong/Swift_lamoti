//
//  AccountViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/08.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    @IBOutlet weak var conditionsCommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conditionsCommentButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
 
    }
    
    @objc func showAlert() {
        
        let alertContorller = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: .alert)
        alertContorller.addTextField { (textField) in
            textField.placeholder = "상태메세지를 입력해주세요"
        }
        alertContorller.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            
            if let textfield = alertContorller.textFields?.first{
                let dic = ["comment":textfield.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
        }))
        alertContorller.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            
        }))
        self.present(alertContorller, animated: true, completion: nil)
    }

}
