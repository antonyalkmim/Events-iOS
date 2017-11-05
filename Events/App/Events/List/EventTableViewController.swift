//
//  EventTableViewController.swift
//  Events
//
//  Created by Antony on 04/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class EventsTableViewController: UITableViewController {
    
    var viewModel : EventListViewModelType!
    private var disposeBag = DisposeBag()
    
    var addEventBarButton: UIBarButtonItem!
    
    // MARK: - Initializers
    
    init(viewModel: EventListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycler
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewConfigurations()
        bindViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear.onNext(())
    }
    
}

// MARK: - Setup
extension EventsTableViewController {
    
    private func setupViewConfigurations() {
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerCell(EventTableViewCell.self)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Events"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .never
            navigationItem.hidesSearchBarWhenScrolling = true
        }
        
        addEventBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        navigationItem.setRightBarButton(addEventBarButton, animated: true)
    }
    
}

// MARK: - Alerts
extension EventsTableViewController {
    private func confirmRemoveEvent() -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] (observer) -> Disposable in
            
            let alert = UIAlertController(title: "Atenção", message: "Deseja remover Evento?", preferredStyle: .actionSheet)
            
            let okAction = UIAlertAction(title: "Confirmar", style: .destructive) { _ in
                observer.on(.next(true))
                observer.on(.completed)
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
                observer.on(.next(false))
                observer.on(.completed)
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self?.present(alert, animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func askRemoveFromCalendar() -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] observer -> Disposable in
            let alert = UIAlertController(title: "Atenção", message: "Deseja remover evento do calendário?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Confirmar", style: .destructive) { _ in
                observer.on(.next(true))
                observer.on(.completed)
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
                observer.on(.next(false))
                observer.on(.completed)
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self?.present(alert, animated: true, completion: nil)
            
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Rx Bindings
extension EventsTableViewController {
    
    private func bindViews() {
        bindOutputs()
        bindInputs()
    }
    
    private func bindOutputs() {
        bindTableView()
    }
    
    private func bindInputs() {
        addEventBarButton.rx.tap
            .bind(to: viewModel.addNewEvent)
            .disposed(by: disposeBag)
    }
    
    private func bindTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<EventListSectionViewModel>(configureCell: { (_ , tableView, indexPath, viewModel) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(type: EventTableViewCell.self, indexPath: indexPath)
            cell.viewModel = viewModel
            return cell
        })
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        dataSource.canEditRowAtIndexPath = { _,_ in return true }
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel
            .cellViewModels
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - Delegate & DataSources
extension EventsTableViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delAction = UITableViewRowAction(style: .destructive, title: "Remover") { [unowned self] (_, indexPath) in
            
            self.confirmRemoveEvent()
                .filter { $0 } //only if confirms delete event
                .flatMapLatest { [weak self] _ -> Observable<Bool> in
                    return self?.askRemoveFromCalendar() ?? Observable.just(false)
                }
                .bind(onNext: { [weak self] shouldRemoveFromCalendar in
                    self?.viewModel.removeEventWithIndex.onNext((index: indexPath.row, deleteFromCalendar: shouldRemoveFromCalendar))
                })
                .disposed(by: self.disposeBag)
        }
        
        return [delAction]
    }
}
