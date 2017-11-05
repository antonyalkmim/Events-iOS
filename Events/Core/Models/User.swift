//
//  User.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var username = ""
    @objc dynamic var birthday = Date(timeIntervalSince1970: 1)
    @objc dynamic var enabledLoginWithTouchId = false
    
    override static func primaryKey() -> String? {
        return "username"
    }
    
}
