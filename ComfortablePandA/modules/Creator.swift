//
//  Creator.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/24.
//

import Foundation

func createKadaiList(rawKadaiList: [AssignmentEntry], count: Int) -> [Kadai] {
    var kadaiList = [Kadai]()
    let lectureInfoList = Loader.shared.loadLectureInfoFromStorage()
    
    for rawEntry in rawKadaiList {
        let id = rawEntry.id
        let lectureName = findLectureName(lectureInfoList: lectureInfoList!, lecID:                                             rawEntry.context)
        let assignmentInfo = rawEntry.title
        let dueDate = Date(timeIntervalSince1970: TimeInterval(rawEntry.dueTime.epochSecond))
        let openDate = Date(timeIntervalSince1970: TimeInterval(rawEntry.openTime.epochSecond))
        let description = rawEntry.instructions.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let isFinished = false
        
        if (dueDate >= Date() && openDate < Date()){
            kadaiList.append(
                Kadai(id: id, lectureName: lectureName, assignmentInfo: assignmentInfo, dueDate: dueDate, description: description ,isFinished: isFinished)
            )
        }
    }
    
    kadaiList = sortKadaiList(kadaiList: kadaiList)
    var validKadaiList = [Kadai]()
    var entryCount = 0
    
    for entry in kadaiList {
        if entryCount >= count { break }
        
        let daysUntil = getDaysUntil(dueDate: entry.dueDate, dispDate: Date())
        
        if daysUntil > 0 {
            validKadaiList.append(entry)
            entryCount += 1
        }
    }
    return validKadaiList
}

func createKadaiList(_kadaiList: [Kadai], count: Int) -> [Kadai] {
    let kadaiList = sortKadaiList(kadaiList: _kadaiList)

    var validKadaiList = [Kadai]()
    var entryCount = 0
    var incompleteEntryCount = 0
    
    for entry in kadaiList {
        if entryCount >= count { break }
        
        let daysUntil = getDaysUntil(dueDate: entry.dueDate, dispDate: Date())
        if daysUntil > 0 {
            if count == 5 {
                if (CPSetting.shared.showDoneAssignments) || (!CPSetting.shared.showDoneAssignments && !entry.isFinished) {
                    validKadaiList.append(entry)
                    entryCount += 1
                }
            }else{
                validKadaiList.append(entry)
                entryCount += 1
            }
            if !entry.isFinished {
                incompleteEntryCount += 1
            }
        }
    }
    if count == 999 { BadgeCount.shared.badgeCount = incompleteEntryCount }
    
    return validKadaiList
}
