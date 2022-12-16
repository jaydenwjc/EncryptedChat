//
//  EncryptedMessageContentView.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/15/22.
//

import UIKit
import StreamChat
import StreamChatUI
import CryptoKit

final class EncryptedMessageContentView: ChatMessageContentView {
    var pinInfoLabel: UILabel?
    
    override func layout(options: ChatMessageLayoutOptions) {
        super.layout(options: options)

        if options.contains(.pinInfo) {
//            backgroundColor = UIColor(red: 0.984, green: 0.957, blue: 0.867, alpha: 1)
            pinInfoLabel = UILabel()
            pinInfoLabel?.font = appearance.fonts.footnote
            pinInfoLabel?.textColor = appearance.colorPalette.textLowEmphasis
            bubbleThreadFootnoteContainer.insertArrangedSubview(pinInfoLabel!, at: 0)
        }
    }
    
    override func updateContent() {
        super.updateContent()
        
//        if let translations = content?.translations, let chineseTranslation = translations[.chineseSimplified] {
//            textView?.text = chineseTranslation
//            timestampLabel?.text?.append(" - Translated to Chinese")
//        }
        
        if content?.isPinned == true, let pinInfoLabel = pinInfoLabel {
            let symmetricKey = ChatManager.shared.getSymmetricKey(cid: self.channel!.cid)
            let decryptedText = Encryption.shared.decrypt(text: (textView?.text)!, symmetricKey: symmetricKey)
//            pinInfoLabel.text?.append("\(decryptedText)")
            textView?.text = decryptedText
            timestampLabel?.text?.append(" - Message Decrypted")
        }
    }
}
