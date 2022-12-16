//
//  EncryptedMessageComposerVC.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/15/22.
//

import UIKit
import StreamChatUI
import CryptoKit

final class EncryptedMessageComposerVC: ComposerVC {
    
    var encryptedMessageComposerView: EncryptedMessageComposerView {
        composerView as! EncryptedMessageComposerView
    }
    
    override func setUp() {
        super.setUp()
        
        encryptedMessageComposerView.sendEncryptedButton.addTarget(self, action: #selector(publishEncryptedMessage), for: .touchUpInside)
    }
    
    
    @objc func publishEncryptedMessage(sender: UIButton) {
        let text: String
        if let command = content.command {
            text = "/\(command.name) " + content.text
        } else {
            text = content.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let editingMessage = content.editingMessage {
            editMessage(withId: editingMessage.id, newText: text)
            
            // This is just a temporary solution. This will be handled on the LLC level
            // in CIS-883
            channelController?.sendStopTypingEvent()
            content.clear()
        } else {
            
            var encryptedText: String!
            
            let symmetricKey = ChatManager.shared.getSymmetricKey(cid: (self.channelController?.channel!.cid)!)
//                let recipient = ChatManager.shared.getRecipient(cid: (self.channelController?.channel!.cid)!)
            do {
                encryptedText = try Encryption.shared.encrypt(text: text, symmetricKey: symmetricKey)
            } catch let error {
                encryptedText = "Could not encrypt message: \(error.localizedDescription)"
            }
            
//            let decryptedText = Encryption.shared.decrypt(text: encryptedText, symmetricKey: symmetricKey)
            createNewMessage(text: encryptedText)
            
            if !content.hasCommand, let cooldownDuration = channelController?.channel?.cooldownDuration {
                cooldownTracker.start(with: cooldownDuration)
            }
            
            content.clear()
        }
    }

}
