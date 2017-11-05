//
//  UITableView+Ext.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit

extension UITableView {
    
    func registerCell(_ cellClass: UITableViewCell.Type) {
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueReusableCell<T: UITableViewCell>(type: T.Type, index: Int) -> T {
        return dequeueReusableCell(type : type, indexPath: IndexPath(row: index, section: 0))
    }
    
    func dequeueReusableCell<T: UITableViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T ?? T()
    }
    
}

