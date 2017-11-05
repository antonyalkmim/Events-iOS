//
//  ViewController.swift
//  Events
//
//  Created by Antony on 03/11/17.
//  Copyright © 2017 Antony. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignupViewController: UIViewController {

    var viewModel: SignupViewModelType!
    private var disposeBag = DisposeBag()
    
    // MARK: - Initializers
    
    init(viewModel: SignupViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycler
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewDidLoad.onNext(())
        
        setupViewConfiguration()
        bindViews()
    }
    
    public lazy var usernameField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Nome de Usuário"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private lazy var datePickerView: UIDatePicker = {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date()
        return datePickerView
    }()
    
    public lazy var dateField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Data de Nascimento"
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.inputView = datePickerView
        return tf
    }()
    
    public lazy var signupButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SignUp", for: .normal)
        button.setTitleColor(UIColor.lightText, for: .highlighted)
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 0.1
        button.layer.borderColor = UIColor.gray.cgColor
        return button
    }()
    
    public lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 0.1
        button.layer.borderColor = UIColor.gray.cgColor
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [signupButton, loginButton])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [usernameField, dateField, buttonsStackView])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 10
        sv.distribution = .fillEqually
        return sv
    }()
    
}

// MARK: - ViewConfiguration
extension SignupViewController: ViewConfiguration {
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
    }
    
}

// MARK: - Actions
extension SignupViewController {
    private func presentAlertFormNotValid() {
        let alertController = UIAlertController(title: "Atenção", message: "Informe um nome de usuário e uma data válida!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func askForRegisterTouchID() {
        let alertController = UIAlertController(title: "Registrar TouchID", message: "Deseja habilitar login com TouchID?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.viewModel.isRegisterWithTouchIDAccepted.onNext(true)
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { [weak self] _ in
            self?.viewModel.isRegisterWithTouchIDAccepted.onNext(false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - Rx Bindings
extension SignupViewController {
    
    private func bindViews() {
        bindOutputs()
        bindInputs()
    }
    
    private func bindOutputs() {
        viewModel.title.bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.birthdayFormatted
            .bind(to: dateField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.presentAlertFormNotValid.bind { [weak self] in
            self?.presentAlertFormNotValid()
        }.disposed(by: disposeBag)
        
        viewModel.askEnableLoginWithTouchID.bind { [weak self] in
            self?.askForRegisterTouchID()
        }.disposed(by: disposeBag)
        
        viewModel.presentAlertInvalidUser.bind { [weak self] in
            self?.presentAlertFormNotValid()
        }.disposed(by: disposeBag)
        
    }
    
    private func bindInputs() {
        
        datePickerView.rx.date
            .asDriver(onErrorJustReturn: Date())
            .drive(viewModel.birthday)
            .disposed(by: disposeBag)
        
        usernameField.rx.text.orEmpty
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] stringValue in
                self?.viewModel.username.value = stringValue
            })
            .disposed(by: disposeBag)
        
        signupButton.rx.controlEvent(.touchUpInside)
            .bind(to: viewModel.signupTapped)
            .disposed(by: disposeBag)
        
        loginButton.rx.controlEvent(.touchUpInside)
            .bind(to: viewModel.loginTapped)
            .disposed(by: disposeBag)
        
    }
    
}
