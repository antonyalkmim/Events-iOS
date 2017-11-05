//
//  SignupViewModelTests.swift
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
import RxTest
import RealmSwift

@testable import Events

class SignupViewModelTests: QuickSpec {
    
    override func spec() {
        
        var vm: SignupViewModelType!
        var disposeBag: DisposeBag!
        var fakeBirthday: Date!
        
        var testRealm: Realm!
        
        beforeSuite {
            Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        }
        
        beforeEach {
            testRealm = try! Realm()
            vm = SignupViewModel(delegate: nil, realm: testRealm)
            disposeBag = DisposeBag()
        }
        
        afterEach {
            vm = nil
            disposeBag = nil
            
            try! testRealm.write {
                testRealm.deleteAll()
            }
        }
        
        describe("when viewDidLoad") {
            describe("and user has already registered fingerprint") {
                
                beforeEach {
                    let user = User(value: [
                        "birthday" : Date(timeIntervalSince1970: 1),
                        "username" : "antonyalkmim",
                        "enabledLoginWithTouchId" : true
                    ])
                    try! testRealm.write {
                        testRealm.add(user)
                    }
                }
                
                it("should request user fingerprint") {
                    var fingerprintRequested: Bool = false
                    
                    vm.askLoginWithTouchID.subscribe(onNext: {
                        fingerprintRequested = true
                    }).disposed(by: disposeBag)
                    
                    vm.viewDidLoad.onNext(())
                    
                    expect(fingerprintRequested) == true
                }
            }
        }
        describe("when user try to signup or login") {
            it("should present alert for invalid info") {
                
                var presentedAlert: Bool!
                
                vm.presentAlertFormNotValid.subscribe(onNext: {
                    presentedAlert = true
                }).disposed(by: disposeBag)
                
                vm.username.value = ""
                vm.birthday.value = Date()
                presentedAlert = false
                vm.signupTapped.onNext(())
                expect(presentedAlert) == true

                vm.username.value = "antonyalkmim"
                vm.birthday.value = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
                presentedAlert = false
                vm.signupTapped.onNext(())
                expect(presentedAlert) == true
                
                vm.username.value = "antonyalkmim" //valid username
                vm.birthday.value = Calendar.current.date(byAdding: .day, value: -2, to: Date())! //two days ago
                presentedAlert = false
                vm.signupTapped.onNext(())
                expect(presentedAlert) == false
            }
            
            context("and filled valid info") {
                beforeEach {
                    fakeBirthday = Calendar.current.date(byAdding: .day, value: -2, to: Date())! //two days ago
                    vm.username.value = "antonyalkmim" //valid username
                    vm.birthday.value = fakeBirthday
                }
                
                it("should register user when tapped signup button") {
                    vm.signupTapped.onNext(())
                    
                    let user = testRealm.object(ofType: User.self, forPrimaryKey: "antonyalkmim")!
                    
                    expect(user.username) == "antonyalkmim"
                    expect(user.birthday) == fakeBirthday
                    expect(user.enabledLoginWithTouchId) == false
                }
                
                context("and new user registered") {
                    
                    it("should clear events") {
                        let event = Events.Event(value: ["about" : "Lorem", "date": Date()])
                        try! testRealm.write { testRealm.add(event) }
                        
                        vm.signupTapped.onNext(())
                        
                        let eventsRegistered = testRealm.objects(Events.Event.self)
                        expect(eventsRegistered.count) == 0
                    }
                    
                    it("should authenticate") {
                        var didAuthenticated = false
                        
                        vm.userDidAuthenticated.subscribe(onNext: {
                            didAuthenticated = true
                        }).disposed(by: disposeBag)
                        
                        vm.signupTapped.onNext(())
                        vm.isRegisterWithTouchIDAccepted.onNext(false)
                        
                        expect(didAuthenticated) == true
                    }
                    
                    it("should ask user to enable login with touchID") {
                        var askedForTouchID: Bool = false
                        
                        vm.askEnableLoginWithTouchID.subscribe(onNext: {
                            askedForTouchID = true
                        }).disposed(by: disposeBag)
                        
                        vm.signupTapped.onNext(())
                        expect(askedForTouchID) == true
                    }
                    
                    context("and tapped login button") {
                        
                        it("should login for valid user") {
                            fakeBirthday = Date(timeIntervalSince1970: 1)
                            
                            let user = User(value: [
                                "birthday" : fakeBirthday,
                                "username" : "antonyalkmim",
                                "enabledLoginWithTouchId" : false
                                ])
                            try! testRealm.write { testRealm.add(user) }
                            
                            var didAuthenticated: Bool = false
                            
                            vm.userDidAuthenticated.subscribe(onNext: {
                                didAuthenticated = true
                            }).disposed(by: disposeBag)
                            
                            //invalid user
                            didAuthenticated = false
                            vm.username.value = "antonyalkmim"
                            vm.birthday.value = Date(timeIntervalSinceNow: 3000)
                            vm.loginTapped.onNext(())
                            expect(didAuthenticated) == false
                            //invalid user
                            didAuthenticated = false
                            vm.username.value = "asd"
                            vm.birthday.value = fakeBirthday
                            vm.loginTapped.onNext(())
                            expect(didAuthenticated) == false
                            //valid user
                            didAuthenticated = false
                            vm.username.value = "antonyalkmim"
                            vm.birthday.value = fakeBirthday
                            vm.loginTapped.onNext(())
                            expect(didAuthenticated) == true
                        }
                    }
                    
                    
                }
                
            }
        }
        
    }
    
}
