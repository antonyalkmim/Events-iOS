//
//  AppCoordinator.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit
import RealmSwift

class AppRouter: CoordinatorType {
    
    var rootController: UIViewController {
        return self.navigationController
    }
    
    private var navigationController : UINavigationController!
    
    func start() {
        presentSignup()
    }
   
}

// MARK: - Routes
extension AppRouter {
    
    private func presentSignup() {
        let viewModel = SignupViewModel(delegate: self, realm: try! Realm())
        let vc = SignupViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: vc)
    }
    
    private func presentEventsList() {
        
    }
    
}

// MARK: - SignupViewModelDelegate
extension AppRouter: SignupViewModelDelegate {
    
    func userDidAuthenticated() {
        presentEventsList()
    }
    
}
