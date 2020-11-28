//
//  Firestore.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/11/27.
//

import FirebaseFirestore
import Firebase




class FireStore {
    
    static let shared = FireStore()
    let db = Firestore.firestore()
    
    func read(colName: String, fieldName: String, UUID: String) -> Bool {
        var res = false
        db.collection(colName).whereField(fieldName, isEqualTo: UUID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    res = true
                }
        }
        return res
    }
    
    func insert(colName: String, UUID: String, token: String) -> () {
        db.collection(colName).document(UUID).setData(
            [ "FCMToken": token ],
        merge: true)
    }
}
