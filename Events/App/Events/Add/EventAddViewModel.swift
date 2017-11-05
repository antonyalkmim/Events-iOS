//
//  EventAddViewModel.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import RxSwift
import RealmSwift

protocol EventAddViewModelType {
    
}

protocol EventAddViewModelDelegate: class {
    func newEventInserted()
}

class EventAddViewModel: EventAddViewModelType {
    
    // MARK: - Privates
    private var disposeBag = DisposeBag()
    
    private var realm: Realm!
    weak var delegate: SignupViewModelDelegate?
    
    
    // MARK: - Initializers
    
    init(delegate: EventAddViewModelDelegate?, realm: Realm) {
        
    }
    
}
