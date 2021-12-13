//
//  User.swift
//  Trilheiros
//
//  Created by Gael on 26/11/21.
//

import Foundation
import RealmSwift


class User: Object {
    @objc dynamic var userId: ObjectId = ObjectId.generate()
    @objc dynamic var name: String = ""
    @objc dynamic var userEmail: String = ""
    @objc dynamic var userImagePath: String = ""
    
    override class func primaryKey() -> String? {
        return "userId"
    }
}
