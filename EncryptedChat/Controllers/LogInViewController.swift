//
//  LogInViewController.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/12/22.
//

import UIKit
import CryptoKit

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
    
    private let privateKeyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Paste your Private Key here"
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .secondarySystemBackground
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let generateKeyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemPink
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Generate Private Key", for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Save this Private Key for future logins!"
        label.textColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var privateKey: String { privateKeyTextField.text ?? "" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Encrypted Chat App"
        view.backgroundColor = .systemBackground

        view.addSubview(usernameTextField)
        view.addSubview(privateKeyTextField)
        view.addSubview(label)
        view.addSubview(generateKeyButton)
        view.addSubview(logInButton)
        addConstraints()
        logInButton.addTarget(self, action: #selector(didTapLogIn), for: .touchUpInside)
        generateKeyButton.addTarget(self, action: #selector(didTapGenerate), for: .touchUpInside)
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
            
            privateKeyTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            privateKeyTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            privateKeyTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50),
            privateKeyTextField.heightAnchor.constraint(equalToConstant: 50),
            
            label.topAnchor.constraint(equalTo: privateKeyTextField.bottomAnchor, constant: 20),
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50),
            
            generateKeyButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40),
            generateKeyButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            generateKeyButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            
            logInButton.topAnchor.constraint(equalTo: generateKeyButton.bottomAnchor, constant: 30),
            logInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            logInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50)
        ])
    }
    
    @objc private func didTapGenerate() {
        let privateKey = Encryption.shared.generatePrivateKey()
        let exportedPrivateKey = Encryption.shared.exportPrivateKey(privateKey)
        self.privateKeyTextField.text = exportedPrivateKey
    }
    
    @objc private func didTapLogIn() {
        usernameTextField.resignFirstResponder()
        guard let username = usernameTextField.text, !username.isEmpty else {
            let alert = UIAlertController(title: "Login Failed",
                                          message: "Username cannot be empty",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        
//        guard let privateKeyText = privateKeyTextField.text, !privateKeyText.isEmpty else {
//            let alert = UIAlertController(title: "Login Failed",
//                                          message: "Generate private key first!",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok",
//                                          style: .default,
//                                          handler: nil))
//            self.present(alert, animated: true)
//            return
//        }
        
        guard let privateKey = try? Encryption.shared.importPrivateKey(self.privateKey) else {
            let alert = UIAlertController(title: "Login Failed",
                                          message: "Could not import private key",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: .default,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let publicKey = privateKey.publicKey
        ChatManager.shared.logIn(with: username, publicKey: publicKey, privateKey: privateKey) { [weak self] success in
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
        let deleteChannel = UIBarButtonItem(barButtonSystemItem: .trash,
                                                               target: self,
                                                               action: #selector(didTapDelete))
        vc.navigationItem.rightBarButtonItems = [createChannel, deleteChannel]
        
        let tabVC = TabBarViewController(chatList: vc)
        tabVC.modalPresentationStyle = .fullScreen
        
        present(tabVC, animated: animated)
    }
    
    @objc private func didTapCompose() {
        let alert = UIAlertController(title: "New Chat",
                                      message: "Please enter recipient username and channel name",
                                      preferredStyle: .alert)
        presentedViewController?.present(alert, animated: true)
        alert.addTextField()
        alert.addTextField()
        let recipientTextField = alert.textFields?.first
        recipientTextField?.placeholder = "Recipient username"
        let channelTextField = alert.textFields?.last
        channelTextField?.placeholder = "Chat channel name"
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Create", style: .default, handler: { _ in
            guard let recipient = recipientTextField?.text, !recipient.isEmpty else {
                return
            }
            guard let name = channelTextField?.text, !name.isEmpty else {
                return
            }
            guard let privateKey = try? Encryption.shared.importPrivateKey(self.privateKey) else {
                let alert = UIAlertController(title: "ERROR",
                                              message: "Could not import private key",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok",
                                              style: .default,
                                              handler: nil))
                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                ChatManager.shared.createNewChat(recipient: recipient, name: name, privateKey: privateKey)
            }
        }))
    }
    
    @objc private func didTapDelete() {
        let alert = UIAlertController(title: "Delete Channel",
                                      message: "Please enter channel name",
                                      preferredStyle: .alert)
        presentedViewController?.present(alert, animated: true)
        alert.addTextField()
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Delete", style: .default, handler: { _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else {
                return
            }
            DispatchQueue.main.async {
                ChatManager.shared.deleteChannel(name: name)
            }
        }))
        
    }
    
    @objc private func didTapNewDM() {
        let alert = UIAlertController(title: "New Chat",
                                      message: "Please enter recipient username and channel name",
                                      preferredStyle: .alert)
        presentedViewController?.present(alert, animated: true)
        alert.addTextField()
        let recipientTextField = alert.textFields?.first
        recipientTextField?.placeholder = "Recipient username"
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Create", style: .default, handler: { _ in
            guard let recipient = recipientTextField?.text, !recipient.isEmpty else {
                return
            }
            guard let privateKey = try? Encryption.shared.importPrivateKey(self.privateKey) else {
                let alert = UIAlertController(title: "ERROR",
                                              message: "Could not import private key",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok",
                                              style: .default,
                                              handler: nil))
                self.present(alert, animated: true)
                return
            }
            DispatchQueue.main.async {
                ChatManager.shared.createNewDM(recipient: recipient, privateKey: privateKey)
            }
        }))
    }
}

