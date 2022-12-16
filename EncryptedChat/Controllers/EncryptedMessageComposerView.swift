//
//  EncryptedMessageComposerView.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/15/22.
//

import UIKit
import StreamChat
import StreamChatUI

class EncryptedMessageComposerView: ComposerView {
    
    lazy var sendEncryptedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "lock.icloud.fill"), for: .normal)
        return button
    }()
    
    override func setUpLayout() {
        super.setUpLayout()
        
        trailingContainer.insertArrangedSubview(sendEncryptedButton, at: 0)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Adjust the input corner radius since width is now bigger
        inputMessageView.container.layer.cornerRadius = 18
    }
}
