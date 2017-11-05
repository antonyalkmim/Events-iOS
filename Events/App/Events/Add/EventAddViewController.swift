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
    
    public lazy var aboutField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Sobre o evento"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private lazy var datePickerView: UIDatePicker = {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.minimumDate = Date()
        return datePickerView
    }()
    
    public lazy var dateField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Data do evento"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.inputView = datePickerView
        return tf
    }()
    
    public lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Adicionar", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 0.1
        button.layer.borderColor = UIColor.gray.cgColor
        return button
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [aboutField, dateField, addButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 10
        sv.distribution = .fillEqually
        return sv
    }()
}

// MARK: - ViewConfiguration
extension EventAddViewController: ViewConfiguration {
    func buildViewHierarchy() {
        view.addSubview(mainStackView)
    }
    
    func setupConstraints() {
        mainStackView
            .heightAnchor(equalToConstant: 150)
            .leadingAnchor(equalTo: view.layoutMarginsGuide.leadingAnchor)
            .trailingAnchor(equalTo: view.layoutMarginsGuide.trailingAnchor)
            .centerXAnchor(equalTo: view.centerXAnchor)
            .centerYAnchor(equalTo: view.centerYAnchor)
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

// MARK: - Alerts
extension EventAddViewController {
    private func presentAlertEventInvalid() {
        let alert = UIAlertController(title: "Atenção", message: "Preencha uma descrição e uma data válida", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentErrorSavingNewEvent() {
        let alert = UIAlertController(title: "Atenção", message: "Erro ao inserir novo evento!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmSaveEventToCalendar() -> Observable<Bool> {
        return Observable<Bool>.create { [weak self] (observer) -> Disposable in
            
            let alert = UIAlertController(title: "Atenção", message: "Deseja adicionar Evento ao calendário?", preferredStyle: .alert)
            
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
    
    private func presentAlertDuplicatedEvent() {
        let alert = UIAlertController(title: "Atenção", message: "Evento ja existente para esta data!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Rx Bindings
extension EventAddViewController {
    
    private func bindViews() {
        bindOutputs()
        bindInputs()
    }
    
    private func bindOutputs() {
        
        viewModel.dateFormatted
            .bind(to: dateField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.presentAlertFormNotValid.bind { [weak self] in
            self?.presentAlertEventInvalid()
        }.disposed(by: disposeBag)
        
        viewModel.presentErrorSavingNewEvent.bind { [weak self] in
            self?.presentErrorSavingNewEvent()
        }.disposed(by: disposeBag)
        
        viewModel.askForSaveEventOnCalendar
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                return self?.confirmSaveEventToCalendar() ?? .just(false)
            }
            .bind(to: viewModel.addEventToCalendar)
            .disposed(by: disposeBag)
        
        viewModel.presentAlertDuplicatedEvent.bind { [weak self] in
            self?.presentAlertDuplicatedEvent()
        }.disposed(by: disposeBag)
    }
    
    private func bindInputs() {
        
        datePickerView.rx.date
            .asDriver(onErrorJustReturn: Date())
            .drive(viewModel.date)
            .disposed(by: disposeBag)
        
        aboutField.rx.text.orEmpty
            .asDriver(onErrorJustReturn: "")
            .drive(viewModel.about)
            .disposed(by: disposeBag)
        
        addButton.rx.controlEvent(.touchUpInside)
            .bind(to: viewModel.addButtonTapped)
            .disposed(by: disposeBag)

    }
}

