//
//  AppCoordinator.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit
import RealmSwift
import Moya

class AppRouter: CoordinatorType {
    
    var rootController: UIViewController {
        return self.navigationController
    }
    
    private var navigationController : UINavigationController!
    
    private var networkingProvider: MoyaProvider<EventsAPI> {
        return appDelegate().networkingProvider
    }
    private let realm = try! Realm()
    
    func start() {
        presentSignup()
    }
   
}

// MARK: - Routes
extension AppRouter {
    
    private func presentSignup() {
        let viewModel = SignupViewModel(delegate: self, realm: realm)
        let vc = SignupViewController(viewModel: viewModel)
        navigationController = UINavigationController(rootViewController: vc)
    }
    
    private func presentEventsList() {
        let viewModel = EventListViewModel(delegate: self, realm: realm)
        let vc = EventsTableViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: true)
    }
    
}

// MARK: - SignupViewModelDelegate
extension AppRouter: SignupViewModelDelegate {
    
    func userDidAuthenticated() {
        presentEventsList()
    }
    
}

// MARK: - EventListViewModelDelegate
extension AppRouter: EventListViewModelDelegate {
    func addNewEvent() {
        let viewModel = EventAddViewModel(delegate: self, networkingProvider: networkingProvider, realm: realm)
        let vc = EventAddViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - EventAddViewModelDelegate
extension AppRouter: EventAddViewModelDelegate {
    func newEventInserted() {
        navigationController.popViewController(animated: true)
    }
}
