//
//  ChatModel.swift
//  Lamoti
//
//  Created by Suhong Jeong on 2020/11/15.
//

import Foundation

class ChatModel : NSObject {
    
    public var users : Dictionary<String,Bool> = [:]
    public var comments : Dictionary<String,Comment> = [:]
    
    public class Comment {
        public var uid : String?
        public var destinationUid : String?
    }
}
