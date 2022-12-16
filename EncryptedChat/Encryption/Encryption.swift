//
//  Encryption.swift
//  EncryptedChat
//
//  Created by Jichu Wang on 12/13/22.
//

import Foundation
import CryptoKit

final class Encryption {
    static let shared = Encryption()
    
    func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
        let privateKey = P256.KeyAgreement.PrivateKey()
        return privateKey
    }
    
    func importPrivateKey(_ privateKey: String) throws -> P256.KeyAgreement.PrivateKey {
        let privateKeyBase64 = privateKey.removingPercentEncoding!
        let rawPrivateKey = Data(base64Encoded: privateKeyBase64)!
        return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
    }
    
    func exportPrivateKey(_ privateKey: P256.KeyAgreement.PrivateKey) -> String {
        let rawPrivateKey = privateKey.rawRepresentation
        let privateKeyBase64 = rawPrivateKey.base64EncodedString()
        let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return percentEncodedPrivateKey
    }
    
    func importPublicKey(_ publicKey: String) throws -> P256.KeyAgreement.PublicKey {
        let base64PublicKey = publicKey.removingPercentEncoding!
        let rawPublicKey = Data(base64Encoded: base64PublicKey)!
        let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: rawPublicKey)
        return publicKey
    }
    
    func exportPublicKey(_ publicKey: P256.KeyAgreement.PublicKey) -> String {
        let rawPublicKey = publicKey.rawRepresentation
        let base64PublicKey = rawPublicKey.base64EncodedString()
        let encodedPublicKey = base64PublicKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return encodedPublicKey
    }
    
    func deriveSymmetricKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "My Key Agreement Salt".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        return symmetricKey
    }
    
    func encrypt(text: String, symmetricKey: SymmetricKey) throws -> String {
        let textData = text.data(using: .utf8)!
        let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
        return encrypted.combined!.base64EncodedString()
    }
    
    func decrypt(text: String, symmetricKey: SymmetricKey) -> String {
        do {
            guard let data = Data(base64Encoded: text) else {
                return "Could not decode text: \(text)"
            }
            
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            guard let text = String(data: decryptedData, encoding: .utf8) else {
                return "Could not decode data: \(decryptedData)"
            }
            
            return text
        } catch let error {
            return "Error decrypting message: \(error.localizedDescription)"
        }
    }
    
    /*
     func testing() {
     let protocolSalt = "Zero Knowledge".data(using: .utf8)!
     /*
      Generate a private key for Alice. Alice guards the private key closely, but publishes the corresponding public key.
      */
     let alicePrivateKey = P256.KeyAgreement.PrivateKey()
     let alicePublicKey = alicePrivateKey.publicKey
     /*:
      Generate a private key for Bob. This happens on Bob’s device. The private key remains known only to Bob, but he publishes the public key.
      */
     let bobPrivateKey = P256.KeyAgreement.PrivateKey()
     let bobPublicKey = bobPrivateKey.publicKey
     /*:
      Alice calculates a shared secret using her private key and Bob’s public key.
      */
     
     let aliceSharedSecret = try! alicePrivateKey.sharedSecretFromKeyAgreement(with: bobPublicKey)
     
     let aliceSymmetricKey = aliceSharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self,
     salt: protocolSalt,
     sharedInfo: Data(),
     outputByteCount: 32)
     /*:
      Bob does the same calculation on his device using his own private key and Alice’s public key.
      */
     
     let bobSharedSecret = try! bobPrivateKey.sharedSecretFromKeyAgreement(with: alicePublicKey)
     
     let bobSymmetricKey = bobSharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self,
     salt: protocolSalt,
     sharedInfo: Data(),
     outputByteCount: 32)
     }
     */
}
