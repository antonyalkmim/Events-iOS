//
//  SignupViewModel.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import RxSwift
import LocalAuthentication
import RealmSwift

protocol SignupViewModelType {
    //inputs
    var birthday: Variable<Date> { get }
    var username: Variable<String> { get }
    var signupTapped: PublishSubject<Void> { get }
    var loginTapped: PublishSubject<Void> { get }
    var isRegisterWithTouchIDAccepted: PublishSubject<Bool> { get }
    var viewDidLoad: PublishSubject<Void> { get }
    
    //outputs
    var title: Observable<String> { get }
    var birthdayFormatted: Observable<String> { get }
    var presentAlertFormNotValid: PublishSubject<Void> { get }
    var presentAlertInvalidUser: PublishSubject<Void> { get }
    var askEnableLoginWithTouchID: PublishSubject<Void> { get }
    var askLoginWithTouchID: PublishSubject<Void> { get }
    var userDidAuthenticated: PublishSubject<Void> { get }
}

protocol SignupViewModelDelegate: class {
    func userDidAuthenticated()
}

class SignupViewModel: SignupViewModelType {
    
    private var disposeBag = DisposeBag()
    
    private var realm: Realm!
    weak var delegate: SignupViewModelDelegate?
    
    //inputs
    let birthday = Variable(Date())
    let username = Variable("")
    
    let signupTapped = PublishSubject<Void>()
    let loginTapped = PublishSubject<Void>()
    var isRegisterWithTouchIDAccepted = PublishSubject<Bool>()
    
    var viewDidLoad = PublishSubject<Void>()
    
    //outputs
    var title: Observable<String> = .just("Signup")
    
    var birthdayFormatted: Observable<String> {
        return birthday.asObservable()
            .map { date -> String in
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                dateFormatter.timeStyle = DateFormatter.Style.none
                return dateFormatter.string(from: date)
            }
    }
    
    var presentAlertFormNotValid = PublishSubject<Void>()
    var presentAlertInvalidUser = PublishSubject<Void>()
    var askEnableLoginWithTouchID = PublishSubject<Void>()
    var askLoginWithTouchID = PublishSubject<Void>()
    var userDidAuthenticated = PublishSubject<Void>()
    
    // initializer
    init(delegate: SignupViewModelDelegate?, realm: Realm) {
        self.delegate = delegate
        self.realm = realm
        
        //has already enable login with touchID
        viewDidLoad
            .map { _ -> Bool in
                let user = realm.objects(User.self).first
                return user?.enabledLoginWithTouchId ?? false
            }
            .bind { [weak self] enabled in
                if enabled {
                    self?.askLoginWithTouchID.onNext(())
                }
            }.disposed(by: disposeBag)
        
        // is form valid
        let isFormValid = Observable.combineLatest(birthday.asObservable(), username.asObservable()) {
            return !$1.isEmpty && $0 < Date()
        }.distinctUntilChanged()

        // signup
        signupTapped.withLatestFrom(isFormValid)
            .subscribe(onNext: { [weak self] isValid in
                guard isValid else {
                    self?.presentAlertFormNotValid.onNext(())
                    return
                }
                self?.registerUser()
            })
            .disposed(by: disposeBag)
        
        // user has accepted register with touchID
        isRegisterWithTouchIDAccepted.bind { [weak self] accepted in
            if accepted {
                self?.registerTouchID()
            } else {
                
            }
        }.disposed(by: disposeBag)
        
        //login
        loginTapped.withLatestFrom(isFormValid)
            .subscribe(onNext: { [weak self] isValid in
                guard isValid else {
                    self?.presentAlertFormNotValid.onNext(())
                    return
                }
                self?.authenticateUser()
            })
            .disposed(by: disposeBag)
        
        userDidAuthenticated.bind {
            delegate?.userDidAuthenticated()
        }.disposed(by: disposeBag)
        
    }
    
    private func authenticateUser() {
        if realm.object(ofType: User.self, forPrimaryKey: username.value) != nil {
            self.userDidAuthenticated.onNext(())
        } else {
            self.presentAlertInvalidUser.onNext(())
        }
    }
    
    private func registerUser() {
        let user = User(value: [
            "birthday" : birthday.value,
            "username" : username.value,
            "enabledLoginWithTouchId" : false
        ])
        
        try! realm.write {
            realm.delete(realm.objects(User.self))
            realm.add(user)
        }
        
        self.askEnableLoginWithTouchID.onNext(())
    }
    
    private func registerTouchID() {
        let context = LAContext()
        let localizedReason = "Login com TouchID"
        
        if(context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) { [weak self] (success, _) in
                if success {
                    try! self?.realm.write {
                        let user = self?.realm.object(ofType: User.self, forPrimaryKey: self?.username.value)
                        user?.enabledLoginWithTouchId = true
                    }
                    self?.userDidAuthenticated.onNext(())
                } else {
                    // TODO: check result LAerror
                }
            }
        }
    }
    
}
