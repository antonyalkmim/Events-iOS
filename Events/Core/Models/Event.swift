//
//  Event.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    @objc dynamic var about = ""
    @objc dynamic var date = Date()
}
