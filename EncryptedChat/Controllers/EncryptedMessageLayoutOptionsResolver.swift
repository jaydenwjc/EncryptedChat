//
//  EncryptedMessageLayoutOptionsResolver.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/15/22.
//

import Foundation
import StreamChat
import StreamChatUI

extension ChatMessageLayoutOption {
    static let pinInfo: Self = "pinInfo"
}

final class EncryptedMessageLayoutOptionsResolver: ChatMessageLayoutOptionsResolver {
    override func optionsForMessage(
            at indexPath: IndexPath,
            in channel: ChatChannel,
            with messages: AnyRandomAccessCollection<ChatMessage>,
            appearance: Appearance
        ) -> ChatMessageLayoutOptions {
            var options = super.optionsForMessage(
                at: indexPath,
                in: channel,
                with: messages,
                appearance: appearance
            )

            let messageIndex = messages.index(messages.startIndex, offsetBy: indexPath.item)
            let message = messages[messageIndex]

            if message.isPinned {
                options.insert(.pinInfo)
            }
            
            return options
        }
}
