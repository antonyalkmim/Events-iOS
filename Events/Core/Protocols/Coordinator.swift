//
//  Coordinator.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit


protocol CoordinatorType: class {
    
    var rootController: UIViewController { get }
    
    func start()
}
