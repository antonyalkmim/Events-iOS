//
//  EventItemViewModel.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation

struct EventCellViewModel {
    
    private let event: Event
    
    var about: String {
        return event.about
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        return dateFormatter.string(from: event.date)
    }
    
    init(event: Event) {
        self.event = event
    }
}
