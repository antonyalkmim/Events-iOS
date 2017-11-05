//
//  EventKitService.swift
//  Events
//
//  Created by Antony on 05/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import EventKit
import RxSwift

class EventKitService {
    
    let eventStore = EKEventStore()
    
    func addEvent(title: String, when: Date) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] (observer) -> Disposable in
            self.eventStore.requestAccess(to: .event, completion: { [unowned self] (granted, _) in
                guard granted else { return }
                
                let newEvent = EKEvent(eventStore: self.eventStore)
                newEvent.calendar = self.eventStore.defaultCalendarForNewEvents
                newEvent.title = title
                newEvent.startDate = when
                newEvent.endDate = when
                newEvent.isAllDay = true
                
                do {
                    try self.eventStore.save(newEvent, span: .thisEvent)
                    DispatchQueue.main.async {
                        observer.on(.next(()))
                        observer.on(.completed)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        observer.on(.error(error))
                    }
                }
            })
            
            return Disposables.create()
        }
    }

    func removeEvent(identifier: String) -> Observable<Void> {
        return Observable<Void>.create { [unowned self] (observer) -> Disposable in
            
            self.eventStore.requestAccess(to: .event, completion: { [unowned self] (granted, _) in
                guard granted else { return }
                
                if let eventSaved = self.eventStore.event(withIdentifier: identifier) {
                    do {
                        try self.eventStore.remove(eventSaved, span: .thisEvent)
                        DispatchQueue.main.async {
                            observer.on(.next(()))
                            observer.on(.completed)
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            observer.on(.error(error))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        observer.on(.completed)
                    }
                }
            })
            
            return Disposables.create()
        }
    }
    
    func getEvents(forDate date: Date) -> Observable<[EKEvent]> {
        return Observable<[EKEvent]>.create { [unowned self] (observer) -> Disposable in
            
            self.eventStore.requestAccess(to: .event, completion: { [unowned self] (granted, _) in
                guard granted else { return }
                
                let initialDate = date.stringValue(withFormat: "dd/MM/yyyy").date(withFormat: "dd/MM/yyyy")!
                let endDate = Calendar.current.date(byAdding: .hour, value: 24, to: initialDate)!
                
                let predicate = self.eventStore.predicateForEvents(withStart: initialDate, end: endDate, calendars: self.eventStore.calendars(for: .event))
                let eventsMathingName = self.eventStore.events(matching: predicate)
                
                DispatchQueue.main.async {
                    observer.on(.next(eventsMathingName))
                    observer.on(.completed)
                }
            })
            
            return Disposables.create()
        }
    }
    
}
