//
//  FirebaseManager.swift
//  FirebaseChatSiwftUI
//
//  Created by uran on 27.03.2023.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: NSObject{
    let auth: Auth
    let firestore: Firestore
//    let storage: Storage
    static let shared = FirebaseManager()
    
   override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
       firestore = Firestore.firestore()
       
        super.init()
    }
}
