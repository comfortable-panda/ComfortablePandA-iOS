//
//  Sakai.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/23.
//

import Foundation

struct Token {
    var LT: String?
    var EXE: String?
}

struct AssignmentCollection: Codable {
    let assignment_collection: [AssignmentEntry]
}

struct AssignmentEntry: Codable, Identifiable {
    let context: String
    let id: String
    let title: String
    let dueTime: AssignmentEntryDueTime
    let openTime: AssignmentEntryOpenTime
    let instructions: String
}

struct AssignmentEntryDueTime: Codable {
    let epochSecond: Int
}

struct AssignmentEntryOpenTime: Codable {
    let epochSecond: Int
}

struct LectureCollection: Codable {
    let site_collection: [LectureInfo]
}
