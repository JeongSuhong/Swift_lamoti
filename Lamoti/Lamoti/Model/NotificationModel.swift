//
//  NotificationModel.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/12/02.
//

import ObjectMapper

class NotificationModel: Mappable {
    
    public var to : String?
    public var notification : Notification = Notification()
    public var data : Data = Data()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
        data <- map["data"]
    }
 
    class Notification: Mappable {
        
        public var title : String?
        public var body : String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            body <- map["body"]
        }
    }
    
    class Data : Mappable {
        
        public var title : String?
        public var body : String?
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            body <- map["body"]
        }
    }
}
