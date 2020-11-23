//
//  ChatModel.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/15.
//

import ObjectMapper

class ChatModel : Mappable {
    
    public var users : Dictionary<String,Bool> = [:]
    public var comments : Dictionary<String,Comment> = [:]
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment : Mappable {
        public var uid : String?
        public var message : String?
        public var time : Int?
        
        public required init?(map:Map) {
            
        }
        func mapping(map:Map) {
            uid <- map["uid"]
            message <- map["message"]
            time <- map["time"]
        }
    }
}
