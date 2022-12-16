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
import CryptoKit

final class ChatManager {
    static let shared = ChatManager()
    
    private var client: ChatClient!
    
    private var privateKey: P256.KeyAgreement.PrivateKey!
    
    public var symmetricKey: SymmetricKey!
    
    private let tokens = [
//        "alice": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYWxpY2UifQ.1TM2hpOF7E0-BX50SdjsCur22x60oodiPOiHlMIPh_c",
//        "bob": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYm9iIn0.lwAUH91HASzKiy2mLSmbcGzi34_LwXkZhgxE1D4RRW8",
//        "coco": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiY29jbyJ9.U_Uo8J-XJKfEyCgjO97ok60n26EJL5y4oVg1frAtqQE",
//        "jayden": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiamF5ZGVuIn0.woMqlRC9pI1GSQfCnY-BOuBxWKzD81PcldnIBC8Dzls",
//        "john": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiam9obiJ9.eyBcrR9GwKSzLSJNuWxpN791ABpHspGzMgM1FVCE2LI",
//        "doe": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZG9lIn0._1NGQgEKvKuedZnK5erCviW0csL-wisTnq2l74x8Yc0",
//        "james": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiamFtZXMifQ.-yEw4nMnNKuDO7goWKGv_cFkrNgeHwMpU9owWeLWwGk"
//        "user1": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidXNlcjEifQ.X_SBaYPmyNKbahp7LLx3ZvopowbIllr3lb1ep24wG_U",
//        "user2": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidXNlcjIifQ.DbPxD1EOkwbsJHPz9Ou4uydARoVm8g-SDXKPD2jI3RU",
//        "testuser1": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidGVzdHVzZXIxIn0.wGd9EsWwvS175lf2anj2_HdJ_EO92SzoCEOZ_wmErVc",
//        "testuser2": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidGVzdHVzZXIyIn0.hRPyJ8e8PRLSbm_I8b4Kd-sefykjFuFS_D9jJfSWdb0",
        "jichu": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiamljaHUifQ.t3Oo7VBNryUBrcqiSgW-b-rrBgMbCKLGx79UcrdMeJQ",
        "parth": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoicGFydGgifQ.AqQaZ5Ya1IhzNQlZQ9BRsx-dPhZH3VraIeDdfQeEA1U"
    ]
    
    func setUp() {
        let config = ChatClientConfig(apiKey: .init("6fbjc8uyttr9"))
        let client = ChatClient(config: config)
        self.client = client
    }
    
    // Authentication
    
    func logIn(with username: String, publicKey: P256.KeyAgreement.PublicKey, privateKey: P256.KeyAgreement.PrivateKey, completion: @escaping (Bool) -> Void) {
        self.privateKey = privateKey
        guard let token = tokens[username.lowercased()] else {
            completion(false)
            return
        }
        
        let exportedPublicKey = Encryption.shared.exportPublicKey(publicKey)
        let publicKeyExtraData: [String: RawJSON] = ["publicKey": .string(exportedPublicKey)]
        
        client.connectUser(
            // imageURL: "https://bit.ly/2TIt8NR"
            userInfo: .init(id: username, extraData: publicKeyExtraData),
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
    
    public func createNewChat(recipient: String, name: String, privateKey: P256.KeyAgreement.PrivateKey) {
        self.privateKey = privateKey
        
        let recipient: [String] = tokens.keys.filter{$0 == recipient}.map{$0}
        
        do {
            let result = try client.channelController(
                createChannelWithId: .init(type: .messaging, id: name),
                name: name,
                members: Set(recipient),
                isCurrentUserMember: true
            )
            result.synchronize()
        } catch {
            print("error")
        }
    }
    
    public func createNewDM(recipient: String, privateKey: P256.KeyAgreement.PrivateKey) {
        self.privateKey = privateKey
        let user: [String] = tokens.keys.filter{$0 == recipient}.map{$0}
        print(Set(user))
        do {
            let result = try client.channelController(createDirectMessageChannelWith: Set(user), extraData: [:])
            result.synchronize()
        } catch {
            print("error")
        }
    }
    
    public func deleteChannel(name: String) {
        let controller = client.channelController(for: .init(type: .messaging, id: name))
        controller.deleteChannel { error in
            if let error = error {
                // handle error
                print(error)
            }
        }
        controller.synchronize()
    }
    
    public func getSymmetricKey(cid: ChannelId) -> SymmetricKey {
        var symmetricKey: SymmetricKey!
        let sender: String = currentUser!
        let recipientId = tokens.keys.filter{$0 != sender}.map{$0}.joined()
        let recipient = client.userController(userId: recipientId)
        recipient.synchronize()
        let recipientPublicKey = (recipient.user?.extraData["publicKey"]?.stringValue)!
        do {
            let importedRecipientPublicKey = try Encryption.shared.importPublicKey(recipientPublicKey)
            let derivedKey = try Encryption.shared.deriveSymmetricKey(privateKey: self.privateKey, publicKey: importedRecipientPublicKey)
            symmetricKey = derivedKey
        } catch {
            print("error")
        }
        return symmetricKey
    }
    /*
    public func getRecipient(cid: ChannelId) -> ChatUser {
        let sender: String = currentUser!
        var recipient: ChatUser!
        let channelController = client.channelController(for: cid)
        channelController.synchronize()
        let membersController = channelController.client.memberListController(query: .init(cid: cid))
        membersController.synchronize()
        print(membersController.members.first{$0.name != sender}?.name)
        let user = channelController.client.userController(userId: (membersController.members.first{$0.name != sender}?.name)!)
        user.synchronize()
        recipient = user.user!
        
       
//        print(membersController.members.count)
        
        return recipient
    }
     */
}
