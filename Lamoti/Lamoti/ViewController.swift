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
    var remoteConfig : RemoteConfig!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch() { [self] (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig.activate() { (changed, error) in
              // ...
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
            
            let message = self.remoteConfig["sever_message"].stringValue
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        logo.image = UIImage(named: "app_logo")
        
        self.view.addSubview(logo)
        logo.snp.makeConstraints { (make) in
        make.center.equalTo(self.view)
            
        }
    }
}

