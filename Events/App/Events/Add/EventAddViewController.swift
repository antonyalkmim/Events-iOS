//
//  AddEventViewController.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EventAddViewController: UIViewController {
    
    var viewModel: EventAddViewModelType!
    private var disposeBag = DisposeBag()
    
    // MARK: - Initializers
    
    init(viewModel: EventAddViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycler
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewConfiguration()
        bindViews()
    }

}

// MARK: - ViewConfiguration
extension EventAddViewController: ViewConfiguration {
    func buildViewHierarchy() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func configureViews() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .never
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        navigationItem.title = "Add Event"
    }
    
}

// MARK: - Rx Bindings
extension EventAddViewController {
    
    private func bindViews() {
        bindOutputs()
        bindInputs()
    }
    
    private func bindOutputs() {
        
    }
    
    private func bindInputs() {
        
    }
}

