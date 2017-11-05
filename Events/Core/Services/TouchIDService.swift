//
//  TouchIDService.swift
//  Events
//
//  Created by Antony on 05/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import Foundation
import LocalAuthentication
import RxSwift
import RxCocoa

class TouchIDService {
    
    let context = LAContext()
    
    func canEvaluatePolicy(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics) -> Observable<Bool> {
        return Observable<Bool>.create { [unowned self] observer in
            if(self.context.canEvaluatePolicy(policy, error: nil)) {
                DispatchQueue.main.async {
                    observer.on(.next(true))
                    observer.on(.completed)
                }
            } else {
                DispatchQueue.main.async {
                    observer.on(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    
    func evaluatePolicy(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics, localizedReason: String) -> Observable<Bool> {
        return Observable.create { [unowned self] (observer) -> Disposable in
            self.context.evaluatePolicy(policy, localizedReason: localizedReason) { (success, _) in
                DispatchQueue.main.async {
                    observer.on(.next(success))
                    observer.on(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
}



