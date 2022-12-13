//
//  LogInViewController.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/12/22.
//

import UIKit

final class LogInViewController: UIViewController {
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "username"
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .secondarySystemBackground
        textField.clearButtonMode = .whileEditing
        return textField
    }()

    private let logInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Log In", for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Encrypted Chat App"
        view.backgroundColor = .systemBackground
        
        view.addSubview(usernameTextField)
        view.addSubview(logInButton)
        addConstraints()
        logInButton.addTarget(self, action: #selector(didTapLogIn), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameTextField.becomeFirstResponder()
        
//        if ChatManager.shared.isLoggedIn {
//            presentChatList(animated: false)
//        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            usernameTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            usernameTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            logInButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 40),
            logInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            logInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50)
        ])
    }
    
    @objc private func didTapLogIn() {
        usernameTextField.resignFirstResponder()
        guard let text = usernameTextField.text, !text.isEmpty else {
            let alert = UIAlertController(title: "Login Failed",
                                          message: "Username cannot be empty",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        ChatManager.shared.logIn(with: text) { [weak self] success in
            guard success else {
                let alert = UIAlertController(title: "Login Failed",
                                              message: "Invalid username",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok",
                                              style: .default,
                                              handler: nil))
                self?.present(alert, animated: true)
                self?.usernameTextField.text = ""
                return
            }
            DispatchQueue.main.async {
                self?.presentChatList()
            }
        }
    }
    
    func presentChatList(animated: Bool = true) {
        guard let vc = ChatManager.shared.createChannelList() else { return }
        
        let createChannel = UIBarButtonItem(barButtonSystemItem: .compose,
                                                               target: self,
                                                               action: #selector(didTapCompose))
        let createDM = UIBarButtonItem(barButtonSystemItem: .add,
                                                               target: self,
                                                               action: #selector(didTapAdd))
        vc.navigationItem.rightBarButtonItems = [createDM, createChannel]
        let tabVC = TabBarViewController(chatList: vc)
        tabVC.modalPresentationStyle = .fullScreen
        
        present(tabVC, animated: animated)
    }
    
    @objc private func didTapCompose() {
        let alert = UIAlertController(title: "New Chat",
                                      message: "Please enter channel name",
                                      preferredStyle: .alert)
        presentedViewController?.present(alert, animated: true)
        alert.addTextField()
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Create", style: .default, handler: { _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else {
//                let alert = UIAlertController(title: "Create Chat Channel Failed",
//                                              message: "Channel name cannot be empty",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok",
//                                              style: .default,
//                                              handler: nil))
//                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                ChatManager.shared.createNewChannel(name: text)
            }
        }))
    }
    
    @objc private func didTapAdd() {
        DispatchQueue.main.async {
            ChatManager.shared.createNewDM()
        }
    }
}

