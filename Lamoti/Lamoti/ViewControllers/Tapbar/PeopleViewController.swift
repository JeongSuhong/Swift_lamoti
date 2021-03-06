//
//  MainViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/12.
//

import UIKit
import SnapKit
import Firebase

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array : [UserModel] = []
    var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeapleViewTableCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.top.equalTo(view)
            m.bottom.left.right.equalTo(view)
        }

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
        
         var selectFrienButton = UIButton()
        view.addSubview(selectFrienButton)
        selectFrienButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view).offset(-90)
            m.right.equalTo(view).offset(-20)
            m.width.height.equalTo(50)
        }
        
        selectFrienButton.backgroundColor = .black
        selectFrienButton.addTarget(self, action: #selector(showSelectFriendController), for: .touchUpInside)
        selectFrienButton.layer.cornerRadius = 25
        selectFrienButton.layer.masksToBounds = true
    }
    
    @objc func showSelectFriendController() {
        self.performSegue(withIdentifier: "SelectFriendSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PeapleViewTableCell
        let imageView = cell.proflieImage!
        imageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(10)
            m.height.width.equalTo(50)
        }
        
        let url = URL(string: array[indexPath.row].profileImageUrl!)
        imageView.layer.cornerRadius = 50 / 2
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: url)

        let label = cell.nameText!
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageView.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].name
        
        let commentLabel = cell.commentText!
        commentLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(cell.commentBGView)
            m.centerY.equalTo(cell.commentBGView)
        }
        
        if let comment = array[indexPath.row].comment {
            commentLabel.text = comment
        }
        
        cell.commentBGView.snp.makeConstraints { (m) in
            m.right.equalTo(cell).offset(-10)
            m.centerY.equalTo(cell)
            
            if let count = commentLabel.text?.count {
                m.width.equalTo(count * 10)
            } else {
                m.width.equalTo(0)
            }
            m.height.equalTo(30)
        }
        
        cell.commentBGView.backgroundColor = UIColor.gray
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.array[indexPath.row].uid
        self.navigationController?.pushViewController(view!, animated: true)
    }
}

class PeapleViewTableCell : UITableViewCell {
    var proflieImage : UIImageView! = UIImageView()
    var nameText : UILabel! = UILabel()
    var commentText : UILabel! = UILabel()
    var commentBGView : UIView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(proflieImage)
        self.addSubview(nameText)
        self.addSubview(commentBGView)
        self.addSubview(commentText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
