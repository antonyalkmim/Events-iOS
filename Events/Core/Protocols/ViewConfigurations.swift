//
//  ViewConfigurations.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation


protocol ViewConfiguration: class {
    
    func buildViewHierarchy()
    func setupConstraints()
    func configureViews()
    
    func setupViewConfiguration()
}

extension ViewConfiguration {
    func setupViewConfiguration() {
        buildViewHierarchy()
        setupConstraints()
        configureViews()
    }
}
