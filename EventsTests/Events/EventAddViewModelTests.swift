//
//  EventAddViewModelTests.swift
//  EventsTests
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxCocoa
import RxBlocking
import RealmSwift
import Moya

@testable import Events

class EventAddViewModelTests: QuickSpec {
    
    override func spec() {
        var vm: EventAddViewModelType!
        var disposeBag: DisposeBag!
        
        var testRealm: Realm!
        var networkingProvider: MoyaProvider<EventsAPI>!
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        }
        
        beforeEach {
            networkingProvider = MoyaProvider<EventsAPI>(stubClosure: MoyaProvider.immediatelyStub)
            testRealm = try! Realm()
            vm = EventAddViewModel(delegate: nil, networkingProvider: networkingProvider, realm: testRealm)
            disposeBag = DisposeBag()
        }
        
        afterEach {
            vm = nil
            disposeBag = nil
            try! testRealm.write { testRealm.deleteAll() }
        }
        
        describe("when try to register new event") {
            it("should validate filled event info") {
                
                var presentedAlert: Bool!
                
                vm.presentAlertFormNotValid.subscribe(onNext: {
                    presentedAlert = true
                }).disposed(by: disposeBag)
                
                vm.about.value = ""
                vm.date.value = Date(timeIntervalSince1970: 1)
                presentedAlert = false
                vm.addButtonTapped.onNext(())
                expect(presentedAlert) == true
                
                vm.about.value = "antonyalkmim"
                vm.date.value = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
                presentedAlert = false
                vm.addButtonTapped.onNext(())
                expect(presentedAlert) == true
                
                vm.about.value = "antonyalkmim" //valid username
                vm.date.value = Calendar.current.date(byAdding: .day, value: 2, to: Date())! //two days ago
                presentedAlert = false
                vm.addButtonTapped.onNext(())
                expect(presentedAlert) == false
                
            }
            
            context("and event is already registered") {
                it("should alert user with duplicated event message") {
                    
                    let testEvent = Events.Event(value: ["about" : "asdfasdf", "date": Date()])
                    
                    try! testRealm.write { testRealm.add(testEvent) }
                    
                    var alertPresented = false
                    vm.presentAlertDuplicatedEvent.subscribe(onNext: {
                        alertPresented = true
                    }).disposed(by: disposeBag)
                    
                    vm.date.value = testEvent.date
                    vm.about.value = testEvent.about
                    vm.addButtonTapped.onNext(())
                    
                    expect(alertPresented) == true
                }
            }
            
            context("and has filled valid event info") {
                
                context("and has registered new event in API") {
                    it("should register new event in local database") {
                        let initialSize = testRealm.objects(Event.self).count
                        
                        let fakeDate = Date()
                        vm.date.value = fakeDate
                        vm.about.value = "Lorem Ipsum"
                        vm.addButtonTapped.onNext(())
                        
                        let finalSize = testRealm.objects(Event.self).count
                        expect(finalSize) == initialSize + 1
                    }
                    
                    it("should ask to add event in phone calendar") {
                        var askedForAddInCalendar = false
                        
                        vm.askForSaveEventOnCalendar.subscribe(onNext: { 
                            askedForAddInCalendar = true
                        }).disposed(by: disposeBag)
                        
                        let fakeDate = Date()
                        vm.date.value = fakeDate
                        vm.about.value = "Lorem Ipsum"
                        vm.addButtonTapped.onNext(())
                        
                        expect(askedForAddInCalendar) == true
                    }
                    
                }
            }
            
        }
        
    }
    
}
