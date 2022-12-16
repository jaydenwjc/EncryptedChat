//
//  EncryptedMessageActionsVC.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/15/22.
//

import Foundation
import UIKit
import StreamChat
import StreamChatUI

final class EncryptedMessageActionsVC: ChatMessageActionsVC {
    // For the propose of the demo app, we add an extra hard delete message to test it.
    override var messageActions: [ChatMessageActionItem] {
        var actions = super.messageActions
        actions.append(pinMessageActionItem())
//        if message?.isBounced == false {
//            actions.append(translateActionItem())
//        }
        return actions
    }
    
    func pinMessageActionItem() -> PinMessageActionItem {
        PinMessageActionItem(
            title: message?.isPinned == false ? "Decrypt Message" : "Undo Decryption",
            icon: message?.isPinned == false ? UIImage(systemName: "lock.open")! : UIImage(systemName: "lock")!,
            action: { [weak self] _ in
                guard let self = self else { return }
                if self.messageController.message?.isPinned == false {
                    self.messageController.pin(.noExpiration) { error in
                        if let error = error {
                            log.error("Error when pinning message: \(error)")
                        }
                        self.delegate?.chatMessageActionsVCDidFinish(self)
                    }
                } else {
                    self.messageController.unpin { error in
                        if let error = error {
                            log.error("Error when unpinning message: \(error)")
                        }
                        self.delegate?.chatMessageActionsVCDidFinish(self)
                    }
                }
            },
            appearance: appearance
        )
    }
    
//    func translateActionItem() -> ChatMessageActionItem {
//        TranslateActionitem(
//            action: { [weak self] _ in
//                guard let self = self else { return }
//                self.messageController.translate(to: .chineseSimplified) { _ in
//                    self.delegate?.chatMessageActionsVCDidFinish(self)
//                }
//            },
//            appearance: appearance
//        )
//    }

    struct PinMessageActionItem: ChatMessageActionItem {
        var title: String
        var isDestructive: Bool { false }
        let icon: UIImage
        let action: (ChatMessageActionItem) -> Void
        
        init(
            title: String,
            icon: UIImage,
            action: @escaping (ChatMessageActionItem) -> Void,
            appearance: Appearance = .default
        ) {
            self.title = title
            self.action = action
            self.icon = icon
        }
    }
    
//    struct TranslateActionitem: ChatMessageActionItem {
//        var title: String { "Translate to Chinese" }
//        var isDestructive: Bool { false }
//        let icon: UIImage
//        let action: (ChatMessageActionItem) -> Void
//
//        init(
//            action: @escaping (ChatMessageActionItem) -> Void,
//            appearance: Appearance = .default
//        ) {
//            self.action = action
//            icon = UIImage(systemName: "character.book.closed")!
//        }
//    }

}
