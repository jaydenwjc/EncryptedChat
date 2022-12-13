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
//        "coco": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY29jbyJ9.U_Uo8J-XJKfEyCgjO97ok60n26EJL5y4oVg1frAtqQE",
//        "jayden": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiamF5ZGVuIn0.woMqlRC9pI1GSQfCnY-BOuBxWKzD81PcldnIBC8Dzls"
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
            userInfo: .init(id: username),
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
    
    public func createChannelList() -> UIViewController? {
        guard let userId = currentUser else { return nil }
        let channelList = client.channelListController(query: .init(filter: .containMembers(userIds: [userId])))
        
        let vc = ChatChannelListVC()
        vc.content = channelList
        
        channelList.synchronize()
        return vc
    }
    
    public func createNewChannel(name: String) {
        guard let current = currentUser else {
            return
        }
        
        let keys: [String] = tokens.keys.filter({ $0 != current }).map { $0 }
        do {
            let result = try client.channelController(
                createChannelWithId: .init(type: .messaging, id: name),
                name: name,
                members: Set(keys),
                isCurrentUserMember: true
            )
            result.synchronize()
        } catch {
            print("error")
        }
    }
    
    public func createNewDM() {
        let users: [String] = tokens.keys.map{$0}
        
        do {
            let result = try client.channelController(createDirectMessageChannelWith: Set(users), extraData: [:])
            result.synchronize()
        } catch {
            print("error")
        }
    }
}
