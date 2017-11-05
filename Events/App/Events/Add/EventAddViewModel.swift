//
//  EventAddViewModel.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import RxSwift
import RealmSwift
import Moya

protocol EventAddViewModelType {
    //inputs
    var date: Variable<Date> { get }
    var about: Variable<String> { get }
    var addButtonTapped: PublishSubject<Void> { get }
    var addEventToCalendar: PublishSubject<Bool> { get }
    
    //outputs
    var dateFormatted: Observable<String> { get }
    var presentAlertFormNotValid: PublishSubject<Void> { get }
    var presentErrorSavingNewEvent: PublishSubject<Void> { get }
    var presentAlertDuplicatedEvent: PublishSubject<Void> { get }
    var askForSaveEventOnCalendar: PublishSubject<Void> { get }
    var finishAddingNewEvent: PublishSubject<Void> { get }
}

protocol EventAddViewModelDelegate: class {
    func newEventInserted()
}

class EventAddViewModel: EventAddViewModelType {
    
    // MARK: - Privates
    private var disposeBag = DisposeBag()
    
    private var networkingProvider: MoyaProvider<EventsAPI>!
    private var realm: Realm!
    weak var delegate: EventAddViewModelDelegate?
    
    private var event = Variable<Event?>(nil)
    
    // MARK: - inputs
    var date = Variable<Date>(Date())
    var about = Variable<String>("")
    var addButtonTapped = PublishSubject<Void>()
    var addEventToCalendar = PublishSubject<Bool>()
    
    // MARK: - outputs
    var dateFormatted: Observable<String> {
        return date.asObservable()
            .map { date -> String in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: date)
        }
    }
    var presentAlertFormNotValid = PublishSubject<Void>()
    var presentErrorSavingNewEvent = PublishSubject<Void>()
    var presentAlertDuplicatedEvent = PublishSubject<Void>()
    var askForSaveEventOnCalendar = PublishSubject<Void>()
    var finishAddingNewEvent = PublishSubject<Void>()
    
    // MARK: - Initializers
    
    init(delegate: EventAddViewModelDelegate?, networkingProvider: MoyaProvider<EventsAPI>, realm: Realm) {
        self.delegate = delegate
        self.realm = realm
        self.networkingProvider = networkingProvider
        
        // is form valid
        let isFormValid = Observable.combineLatest(date.asObservable(), about.asObservable()) {
            return !$1.isEmpty && (Calendar.current.isDateInToday($0) || $0 > Date())
        }.distinctUntilChanged()
        
        // add event invalid form
        addButtonTapped.withLatestFrom(isFormValid)
            .subscribe(onNext: { [weak self] isValid in
                guard isValid else {
                    self?.presentAlertFormNotValid.onNext(())
                    return
                }
                
                if let strongSelf = self {
                    let duplicatedEvents = realm.objects(Event.self).filter {
                        return $0.about == strongSelf.about.value
                            && $0.date.isSameDay(of: strongSelf.date.value)
                    }
                    if !duplicatedEvents.isEmpty {
                        self?.presentAlertDuplicatedEvent.onNext(())
                    } else {
                        self?.addNewEvent()
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        //add event to calendar
        addEventToCalendar.bind { [weak self] shouldAdd in
            if shouldAdd {
                self?.addCalendarEvent()
            } else {
                self?.finishAddingNewEvent.onNext(())
            }
        }.disposed(by: disposeBag)
        
        // finish adding event
        finishAddingNewEvent
            .bind { [weak self] in self?.delegate?.newEventInserted()}
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - Actions
extension EventAddViewModel {
    
    private func addNewEvent() {
        event.value = Event(value: [
            "about" : about.value,
            "date" : date.value
        ])
        
        networkingProvider.rx
            .request(.addEvent(event: event.value!))
            .mapTo(EventsAPIResponse.self)
            .subscribe(onSuccess: { [weak self] (response) in
                guard response.status else {
                    self?.presentErrorSavingNewEvent.onNext(())
                    return
                }
                
                if let eventSaved = self?.event.value {
                    try! self?.realm.write { self?.realm.add(eventSaved) }
                    self?.askForSaveEventOnCalendar.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func addCalendarEvent() {
        if let eventSaved = event.value {
            
            finishAddingNewEvent.onNext(())
        }
    }
}
