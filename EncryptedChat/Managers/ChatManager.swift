//
//  ChatManager.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/12/22.
//

import Foundation
import StreamChat
import StreamChatUI
import UIKit

final class ChatManager {
    static let shared = ChatManager()
    
    private var client: ChatClient!
    
    private let tokens = [
        "alice": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYWxpY2UifQ.1TM2hpOF7E0-BX50SdjsCur22x60oodiPOiHlMIPh_c",
        "bob": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYm9iIn0.lwAUH91HASzKiy2mLSmbcGzi34_LwXkZhgxE1D4RRW8",
        "coco": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY29jbyJ9.U_Uo8J-XJKfEyCgjO97ok60n26EJL5y4oVg1frAtqQE",
        "jayden": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiamF5ZGVuIn0.woMqlRC9pI1GSQfCnY-BOuBxWKzD81PcldnIBC8Dzls"
    ]
    
    func setUp() {
        let config = ChatClientConfig(apiKey: .init("6fbjc8uyttr9"))
        let client = ChatClient(config: config)
        self.client = client
    }
    
    // Authentication
    
    func logIn(with username: String, completion: @escaping (Bool) -> Void) {
        guard let token = tokens[username.lowercased()] else {
            completion(false)
            return
        }
        
        client.connectUser(
            // imageURL: "https://bit.ly/2TIt8NR"
            userInfo: UserInfo(id: username, name: username),
            token: Token(stringLiteral: token)
        ) { error in
            completion(error == nil)
        }
    }
    
    func logOut() {
        client.disconnect()
        client.logout()
    }
    
    var isLoggedIn: Bool {
        return client.currentUserId != nil
    }
    
    var currentUser: String? {
        return client.currentUserId
    }
    
    // ChannelList
    
    public func createChannelList() -> UIViewController {
        return UIViewController()
    }
    
    public func createNewChannel(name: String) {
        
    }
}
