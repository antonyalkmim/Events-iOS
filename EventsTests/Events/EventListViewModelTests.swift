//
//  EventListViewModelTests.swift
//  EventsTests
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RealmSwift
import RxDataSources

@testable import Events

func makeEvents() -> [Events.Event] {
    let now = Date()
    
    return [0, 1, 2].map { index -> Events.Event in
        let event = Event()
        event.about = "Lorem Ipsum \(index + 1)"
        event.date = now.addingTimeInterval(TimeInterval(5000 + (1000 * index)))
        return event
    }
    
}


class EventListViewModelTests: QuickSpec {
    
    override func spec() {
        
        var vm: EventListViewModelType!
        var disposeBag: DisposeBag!
        
        var testRealm: Realm!
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        }
        
        beforeEach {
            testRealm = try! Realm()
            vm = EventListViewModel(delegate: nil, realm: testRealm)
            disposeBag = DisposeBag()
        }
        
        afterEach {
            vm = nil
            disposeBag = nil
            
            try! testRealm.write {
                testRealm.deleteAll()
            }
        }
        
        it("should list events from localdatabase") {
            let events = makeEvents()
            try! testRealm.write {
                testRealm.add(events)
            }
            
            vm.viewDidAppear.onNext(())
            let cellsViewModels = try! vm.cellViewModels.toBlocking().first()![0].items
            
            expect(cellsViewModels.count) == 3
            expect(cellsViewModels[0].about) == "Lorem Ipsum 1"
            expect(cellsViewModels[1].about) == "Lorem Ipsum 2"
            expect(cellsViewModels[2].about) == "Lorem Ipsum 3"
        }
        
        describe("user wants to remove event") {
            it("should remove event from local database") {
                let events = makeEvents()
                try! testRealm.write { testRealm.add(events) }
                
                vm.viewDidAppear.onNext(())
                vm.removeEventWithIndex.onNext((index: 1, deleteFromCalendar: false))
                
                let cellsViewModels = try! vm.cellViewModels.toBlocking().first()![0].items
                expect(cellsViewModels.count) == 2
                expect(cellsViewModels[0].about) == "Lorem Ipsum 1"
                expect(cellsViewModels[1].about) == "Lorem Ipsum 3"
                
                let registeredEvents = testRealm.objects(Events.Event.self)
                expect(registeredEvents.count) == 2
                expect(registeredEvents[0].about) == "Lorem Ipsum 1"
                expect(registeredEvents[1].about) == "Lorem Ipsum 3"
            }
        }
    }
    
}
