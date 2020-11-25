//
//  Demo.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/11/25.
//

import SwiftUI

class Demo {
    static let shared = Demo()
    
    func loadDemoLectureInfo() -> [LectureInfo] {
        let loadLectureInfo = [
            LectureInfo(id: "demo1", title: "Algebra 1"),
            LectureInfo(id: "demo2", title: "English Composition B"),
            LectureInfo(id: "demo3", title: "Introduction to CS")
        ]
        return loadLectureInfo
    }
    
    func loadDemoKadaiList() -> [Kadai] {
        let loadKadaiList = [
           Kadai(id: "0001", lectureName: "Algebra 1", assignmentInfo: "Assesment #1", dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!, description: "", isFinished: false),
            Kadai(id: "0002", lectureName: "Algebra 1", assignmentInfo: "Assesment #2", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, description: "", isFinished: false),
            Kadai(id: "0003", lectureName: "English Composition B", assignmentInfo: "Pre study", dueDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, description: "", isFinished: false),
            Kadai(id: "0004", lectureName: "Introduction to CS", assignmentInfo: "Machine Learning 1", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, description: "", isFinished: false),
            Kadai(id: "0005", lectureName: "Introduction to CS", assignmentInfo: "C# intro", dueDate: Calendar.current.date(byAdding: .day, value: 25, to: Date())!, description: "", isFinished: false)
        ]
        return loadKadaiList
    }
    
}
