//
//  miniPandA.swift
//  miniPandA
//
//  Created by das08 on 2020/10/02.
//

import WidgetKit
import SwiftUI

struct KadaiEntry: TimelineEntry {
    let date: Date
    let kadai: [Kadai]
}

struct Provider: TimelineProvider {
    
    @AppStorage("kadai", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    var storedKadaiList: Data = Data()
    
    
    func getSnapshot(in context: Context, completion: @escaping (KadaiEntry) -> Void) {
        let kadaiEntrySample = [
            Kadai(id: "s1", lectureName: "Lec1", assignmentInfo: "Quiz1", dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s2", lectureName: "Lec2", assignmentInfo: "Quiz2", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s3", lectureName: "Lec3", assignmentInfo: "Assignment3", dueDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s4", lectureName: "Lec4", assignmentInfo: "Assignment4", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s5", lectureName: "Lec5", assignmentInfo: "Quiz5", dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, description: "", isFinished: false),
        ]
        let entry = KadaiEntry(date: Date(), kadai: kadaiEntrySample)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<KadaiEntry>) -> Void) {
        var entries = [KadaiEntry]()
        let currentDate = Date()
        
        let loadKadaiList = Loader.shared.loadKadaiListFromStorage2()
        let kadaiList = createKadaiList(_kadaiList: loadKadaiList, count: 5)
        
        // Create Timeline object for an hour
        for offset in 0 ..< 2 {
            let entryDate: Date = Calendar.current.date(byAdding: .minute, value: offset, to: currentDate)!
            var dispDateModified_kadaiList = [Kadai]()

            for var entry in kadaiList {
                entry.dispDate = entryDate
                dispDateModified_kadaiList.append(entry)
            }
            entries.append(KadaiEntry(date: entryDate, kadai:dispDateModified_kadaiList))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    
    func placeholder(in context: Context) -> KadaiEntry {
        let kadaiEntrySample = [
            Kadai(id: "s1", lectureName: "Lec1", assignmentInfo: "Quiz1", dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s2", lectureName: "Lec2", assignmentInfo: "Quiz2", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s3", lectureName: "Lec3", assignmentInfo: "Assignment3", dueDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s4", lectureName: "Lec4", assignmentInfo: "Assignment4", dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, description: "", isFinished: false),
            Kadai(id: "s5", lectureName: "Lec5", assignmentInfo: "Quiz5", dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, description: "", isFinished: false),
        ]
        return KadaiEntry(date: Date(), kadai: kadaiEntrySample)
    }
}


struct WidgetEntryView: View {
    let entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
//        case .systemMedium:
//            KadaiView(kadai: entry.kadai)
//
        default:
            KadaiViewLarge(kadaiList: entry.kadai)
        }
        
    }
}

@main
struct miniPandAWidget: Widget {
    private let kind = "miniPandA"
    let mpColor = miniPandAColor()
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) {entry in
            WidgetEntryView(entry: entry)
                .background(mpColor.background)
        }
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("miniPandA")
        .description("取得した課題一覧をウィジェットで簡単に確認できます")
    }
}
