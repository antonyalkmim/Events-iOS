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
    private var touchIDService = TouchIDService()
    
    //inputs
    let birthday = Variable(Date())
    let username = Variable("")
    
    let signupTapped = PublishSubject<Void>()
    let loginTapped = PublishSubject<Void>()
    var isRegisterWithTouchIDAccepted = PublishSubject<Bool>()
    
    var viewDidLoad = PublishSubject<Void>()
    
    //outputs
    
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
            .flatMapLatest { _ -> Observable<Bool> in
                let user = realm.objects(User.self).first
                return Observable<Bool>.just(user?.enabledLoginWithTouchId ?? false)
            }
            .filter { $0 }
            .map { _ in return Observable<Void>.just(()) }
            .bind(to: askLoginWithTouchID)
            .disposed(by: disposeBag)
        
        askLoginWithTouchID
            .flatMapLatest { [unowned self] _ -> Observable<Bool> in return self.touchIDService.canEvaluatePolicy() }
            .filter { $0 }
            .flatMapLatest { [unowned self] _ -> Observable<Bool> in return self.touchIDService.evaluatePolicy(localizedReason: "Login com TouchID") }
            .filter { $0 }
            .bind { [weak self] _ in self?.userDidAuthenticated.onNext(()) }
            .disposed(by: disposeBag)
        
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
        
        // user has accepted/unaccepted register with touchID
        isRegisterWithTouchIDAccepted
            .flatMapLatest { [unowned self] (accepted) -> Observable<Bool> in
                guard accepted else { return .just(false) }
                return self.touchIDService
                    .canEvaluatePolicy()
                    .flatMapLatest { [unowned self] _ -> Observable<Bool> in
                        return self.touchIDService.evaluatePolicy(localizedReason: "Login com TouchID")
                    }
            }
            .flatMapLatest(registerTouchId)
            .bind(to: userDidAuthenticated)
            .disposed(by: disposeBag)
        
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
        
        userDidAuthenticated
            .bind { delegate?.userDidAuthenticated()}
            .disposed(by: disposeBag)
        
    }
    
    private func authenticateUser() {
        let user = realm.object(ofType: User.self, forPrimaryKey: username.value)
        
        if user != nil && user!.birthday.isSameDay(of: birthday.value) {
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
            realm.deleteAll()
            realm.add(user)
        }
        
        self.askEnableLoginWithTouchID.onNext(())
    }
    
    private func registerTouchId(accepted: Bool) -> Observable<Void> {
        return Observable<Void>.create { [weak self] observer in
            try! self?.realm.write {
                let user = self?.realm.object(ofType: User.self, forPrimaryKey: self?.username.value)
                user?.enabledLoginWithTouchId = accepted
            }
            observer.on(.next(()))
            observer.on(.completed)
            return Disposables.create()
        }
    }
    
}
