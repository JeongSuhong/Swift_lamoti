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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let imageView = UIImageView()
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(10)
            m.height.width.equalTo(50)
        }
        
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { (data, response, error) in
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
                imageView.layer.cornerRadius = imageView.frame.size.width / 2
                imageView.clipsToBounds = true
            }
        }.resume()
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageView.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].name
        
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
