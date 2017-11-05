//
//  EventListViewModel.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxDataSources
import EventKit

typealias EventListSectionViewModel = SectionModel<String, EventCellViewModel>

protocol EventListViewModelType {
    //inputs
    var viewDidAppear: PublishSubject<Void> { get }
    var removeEventWithIndex: PublishSubject<(index: Int, deleteFromCalendar: Bool)> { get }
    var addNewEvent: PublishSubject<Void> { get }
    
    //outputs
    var cellViewModels : Observable<[EventListSectionViewModel]> { get }
}

protocol EventListViewModelDelegate: class {
    func addNewEvent()
}

class EventListViewModel: EventListViewModelType {
    
    private var disposeBag = DisposeBag()
    weak var delegate: EventListViewModelDelegate?
    private var realm: Realm!
    private let eventStore = EKEventStore()
    
    private var token: NotificationToken?
    
    private let events = Variable<[Event]>([])
    
    //inputs
    var viewDidAppear = PublishSubject<Void>()
    var removeEventWithIndex = PublishSubject<(index: Int, deleteFromCalendar: Bool)>()
    var addNewEvent = PublishSubject<Void>()
    
    //outputs
    var cellViewModels: Observable<[EventListSectionViewModel]> {
        return events
            .asObservable()
            .map {
                let vms = $0.map(EventCellViewModel.init)
                let section = EventListSectionViewModel(model: "", items: vms)
                return [section]
        }
    }
    
    //initializers
    init(delegate: EventListViewModelDelegate?, realm: Realm) {
        self.delegate = delegate
        self.realm = realm
        
        //when viewDidLoad should load events
        viewDidAppear
            .map { realm.objects(Event.self).map { $0 } }
            .bind(to: events)
            .disposed(by: disposeBag)
        
        // delete event
        removeEventWithIndex
            .bind { [weak self] (index, deleteFromCalendar) in
                self?.deleteEvent(forIndex: index, deleteFromCalendar: deleteFromCalendar)
            }
            .disposed(by: disposeBag)
        
        //add event
        addNewEvent
            .bind { delegate?.addNewEvent() }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Actions
extension EventListViewModel {
    private func deleteEvent(forIndex index: Int, deleteFromCalendar: Bool) {
        let event = events.value[index]
        
        if deleteFromCalendar {
            //TODO: delete from calendar
        }
        
        try! realm.write { realm.delete(event) }
        events.value = realm.objects(Event.self).map { $0 }
    }
}
