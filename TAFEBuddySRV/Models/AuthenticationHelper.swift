//
//  AuthenticationHelper.swift
//  TAFEBuddySRV
//
//  Created by Jefferson Gomes on 14/2/20.
//  Copyright © 2020 Jefferson Gomes. All rights reserved.
//

import Foundation
import Alamofire
import Security

class AuthenticationHelper {
    let clientId : String = "0oa2br9xrvoqO7GgR357"
    let clientSecret : String = "mqgjAiv4pRuae-whLK-vjWckTVLRCR7htIe35Vxo"
    let scope : String = "tafebuddy_student"
    let issuer : String = "https://dev-191448.okta.com/oauth2/default"
    let tokenTagKeychain : String = "com.tafe.tafebuddysrv.accessToken"
    let tokenExpireTagKeychain : String = "com.tafe.tafebuddysrv.accessTokenExpire"
    
    func ObtainToken(completion:@escaping (String?, Error?) -> Void) {
        
        if let key = keychainDataToString(tag: tokenTagKeychain),
            let date = keychainDataToString(tag: tokenExpireTagKeychain){
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            if let dateTime = formatter.date(from: date) {
                if dateTime >= Date() {
                    completion(key, nil)
                    return
                }
            }
        }
        
        let url = "\(issuer)/v1/token"
          
        let str = clientId + ":" + clientSecret

        let token = Data(str.utf8).base64EncodedString()
        
        let parameters = [
            "grant_type": "client_credentials",
            "scope": scope
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(token)"
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   headers: headers)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .success:
                guard let value = response.value as? [String: Any] else {
                    print("Error converting JSON")
                    completion(nil,LoginError.generalError)
                    return
                }
                
                let accessToken = value["access_token"] as? String
                let tokenType = value["token_type"] as? String
                let expire = value["expires_in"] as! Double
                let date = Date().addingTimeInterval(expire)
                let auth = "\(tokenType!) \(accessToken!)"
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                let stringDateTime = formatter.string(from: date)
                
                if self.storeDataInKeyChain(tag: self.tokenTagKeychain, key: auth) {
                    if self.storeDataInKeyChain(tag: self.tokenExpireTagKeychain, key: stringDateTime) {
                        print("Both Key successfully stored")
                    } else {
                        self.resetKeychain()
                    }
                } else {
                    print("error storing")
                    self.resetKeychain()
                }
                completion(auth, nil)
                
            case let .failure(error):
                print("Erro getting token \(error)")
                completion(nil,LoginError.generalError)
            }
        }
    }
    
    func refreshToken(completion:@escaping (String?, Error?) -> Void) {
        let url = "\(issuer)/v1/token"
          
        let str = clientId + ":" + clientSecret

        let token = Data(str.utf8).base64EncodedString()
        
        let parameters = [
            "grant_type": "client_credentials",
            "scope": scope
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(token)"
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   headers: headers)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .success:
                guard let value = response.value as? [String: Any] else {
                    print("Error converting JSON")
                    completion(nil,LoginError.generalError)
                    return
                }
                
                let accessToken = value["access_token"] as? String
                let tokenType = value["token_type"] as? String
                let expire = value["expires"] as! Double
                let date = Date().addingTimeInterval(expire)
                let auth = "\(tokenType!) \(accessToken!)"
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                let stringDateTime = formatter.string(from: date)
                
                if self.storeDataInKeyChain(tag: self.tokenTagKeychain, key: auth) {
                    if self.storeDataInKeyChain(tag: self.tokenExpireTagKeychain, key: stringDateTime) {
                        print("Both Key successfully stored")
                    } else {
                        self.resetKeychain()
                    }
                } else {
                    print("error storing")
                    self.resetKeychain()
                }
                completion(auth, nil)
                
            case let .failure(error):
                print("Erro getting token \(error)")
                completion(nil,LoginError.generalError)
            }
        }
    }
    
    func getDataFromKeychain(tag: String) -> Data? {
        let getquery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to retrieve data for key '\(tag)', error: \(status)")
        }
        return item as? Data
    }
    
    func storeDataInKeyChain(tag: String, key: String) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!
        ]
        
        let update:[String: Any] = [
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        var status = errSecSuccess
        // Check if key already exists
         if getDataFromKeychain(tag: tag) != nil {
            status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        } else {
            for (key, value) in update {
                query[key] = value
            }
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        if status != errSecSuccess {
            print("Failed to set data for key '\(key)', error: \(status)")
            return false
        }

        return true
    }
    
    func keychainDataToString(tag: String) -> String? {
        guard let data = getDataFromKeychain(tag: tag) else {
            return nil
        }
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
    }
    
    #if os(iOS) || os(watchOS)
    /**
    Remove all objects from the keychain for the current app. Only available on
    iOS and watchOS.
    */
    @discardableResult public func resetKeychain() -> Bool {
        let query:[String: AnyObject] = [kSecClass as String : kSecClassKey]
        
        let status = SecItemDelete(query as CFDictionary)
        print("status: \(status)")
        if status != errSecSuccess {
            print("Latch failed to reset keychain, error: \(status)")
            return false
        }

        return true
    }
    #endif
}
