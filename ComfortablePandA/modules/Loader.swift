//
//  Loader.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/04.
//

import Foundation
import SwiftUI


class Loader {
    static let shared = Loader()
    
    @AppStorage("lastKadaiFetched", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var storedKadaiFetchedTime: Data = Data()
    
    @AppStorage("kadai", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var storedKadaiList: Data = Data()

    @AppStorage("lectureInfo", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var storedLectureInfo: Data = Data()
    
    @AppStorage("demo", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var isDemoMode: Data = Data()
    
    func loadKadaiFetchedTimeFromStorage() -> String {
        var loadKadaiFetchedTime: Date
        guard let load = try? JSONDecoder().decode(Date.self, from: storedKadaiFetchedTime) else {
            return "未取得"
        }
        
        loadKadaiFetchedTime = load
        return dispDate(date: loadKadaiFetchedTime)
    }
    
    func loadLectureInfoFromStorage() -> [LectureInfo]? {
        var loadLectureInfo: [LectureInfo]
        guard let load = try? JSONDecoder().decode([LectureInfo].self, from: storedLectureInfo) else {
            let loadLectureInfo = SakaiAPI.shared.getLectureInfoList()
            return loadLectureInfo
        }
        
        if load == [LectureInfo]() { loadLectureInfo = SakaiAPI.shared.getLectureInfoList(); print("11") }
        else{ loadLectureInfo = load }
        
        return loadLectureInfo
    }
    
    func loadKadaiListFromStorage() -> [Kadai]? {
        var loadKadaiList: [Kadai]
        guard let load = try? JSONDecoder().decode([Kadai].self, from: storedKadaiList) else {
            let rawKadaiList = SakaiAPI.shared.getRawKadaiList()
            let kadaiList = createKadaiList(rawKadaiList: rawKadaiList, count: 999)
            Saver.shared.saveKadaiListToStorage(kadaiList: kadaiList)
            print("fetched from panda and loaded")
            return kadaiList
        }
        loadKadaiList = load
        return loadKadaiList
    }
    
    func loadKadaiListFromStorage2() -> [Kadai] {
        var loadKadaiList: [Kadai]
        guard let load = try? JSONDecoder().decode([Kadai].self, from: storedKadaiList) else {
            return [Kadai]()
        }
        loadKadaiList = load
        return loadKadaiList
    }
    
    func loadDemoFlag() -> Bool {
        var demoMode: Bool
        guard let load = try? JSONDecoder().decode(Bool.self, from: isDemoMode) else {
            return false
        }
        demoMode = load
        return demoMode
    }
}

func sortKadaiList(kadaiList: [Kadai]) -> [Kadai] {
    return kadaiList.sorted { (l: Kadai, r: Kadai) in
//        if (l.dueDate! < r.dueDate!) {return (l.dueDate! < r.dueDate!)}
//        if (l.dueDate! > r.dueDate!) {return (l.dueDate! > r.dueDate!)}
//        if (l.assignmentInfo < r.assignmentInfo) {return (l.assignmentInfo < r.assignmentInfo)}
//        if (l.assignmentInfo > r.assignmentInfo) {return (l.assignmentInfo > r.assignmentInfo)}
//        return true
        return (l.dueDate < r.dueDate)
    }
}
