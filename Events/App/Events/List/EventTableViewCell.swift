//
//  EventTableViewCell.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    var viewModel: EventCellViewModel! {
        didSet {
            bindUI()
        }
    }
    
    // MARK: - Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindUI() {
        textLabel?.text = viewModel.about
        detailTextLabel?.text = viewModel.formattedDate
    }
    
}
