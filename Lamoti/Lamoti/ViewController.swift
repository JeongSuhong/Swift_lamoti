//
//  ViewController.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/10/21.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {

    let logo = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
        logo.image = UIImage(named: "app_logo")
        
        self.view.addSubview(logo)
        logo.snp.makeConstraints { (make) in
        make.center.equalTo(self.view)
        }
        
    }
}

