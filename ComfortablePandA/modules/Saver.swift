//
//  Saver.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/06.
//

import Foundation
import SwiftUI

class Saver {
    static let shared = Saver()
    
    @AppStorage("lastKadaiFetched", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var storedKadaiFetchedTime: Data = Data()
    
    @AppStorage("kadai", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var storedKadaiList: Data = Data()

    @AppStorage("lectureInfo", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var storedLectureInfo: Data = Data()
    
    @AppStorage("demo", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var isDemoMode: Data = Data()
    
    func saveKadaiFetchedTimeToStorage() -> () {
        let currentDate = Date()
        guard let save = try? JSONEncoder().encode(currentDate) else { return }
        self.storedKadaiFetchedTime = save
        print("saved FetchedTime")
    }
    
    func saveLectureInfoToStorage(lectureInfoList: [LectureInfo]) -> () {
        guard let save = try? JSONEncoder().encode(lectureInfoList) else { return }
        self.storedLectureInfo = save
        print(lectureInfoList)
        print("saved lecID")
    }
    
    func saveKadaiListToStorage(kadaiList: [Kadai]) -> () {
//        For just saving kadaiList
        guard let save = try? JSONEncoder().encode(kadaiList) else { return }
        
        self.storedKadaiList = save
        print("saved kadaiList")
    }
    
    func mergeAndSaveKadaiListToStorage(newKadaiList: [Kadai]) -> () {
//        For saving newly fetched kadaiList
//        let oldKadaiList = createKadaiList(_kadaiList: Loader.shared.loadKadaiListFromStorage()!, count: 999)
        let oldKadaiList = createKadaiList(_kadaiList: Loader.shared.loadKadaiListFromStorage2(), count: 999)
        
        let mergedKadaiList = mergeKadaiList(oldKL: oldKadaiList, newKL: newKadaiList)
        
        guard let save = try? JSONEncoder().encode(mergedKadaiList) else { return }
        
        self.storedKadaiList = save
        print("saved kadaiList")
    }
    
    func setDemoFlag(demo: Bool) -> () {
        guard let save = try? JSONEncoder().encode(demo) else { return }
        self.isDemoMode = save
        print("saved demo mode settings")
    }
}

func saveKeychain(account: String, value: String) -> saveResultMessage {
    var result = saveResultMessage()
    do {
        try Keychain.set(value: value.data(using: .utf8)!, account: account)
        result.success = true
    }
    catch {
        
    }
    return result
}

struct saveResultMessage {
    var success: Bool = false
    var errorMsg :Keychain.Errors = Keychain.Errors.keychainError
}

func mergeKadaiList(oldKL: [Kadai], newKL: [Kadai]) -> [Kadai] {
    var mergedKadaiList = [Kadai]()
    var incompleteEntryCount = 0
    
    for var newEntry in newKL {
        let nKid = newEntry.id
        var oExist = false
        
        for oldEntry in oldKL {
            let oKid = oldEntry.id
            
            if nKid == oKid {
                newEntry.isFinished = oldEntry.isFinished
                oExist = true
            }
        }
        mergedKadaiList.append(newEntry)
        if (!oExist){
            setNotification(title: "📗新規課題", body: "\(dispDate(date: newEntry.dueDate)) \(newEntry.lectureName)\n\(newEntry.assignmentInfo)")
        }
        if !newEntry.isFinished {
            incompleteEntryCount += 1
        }
    }
    
    BadgeCount.shared.badgeCount = incompleteEntryCount
    
    return mergedKadaiList
}
