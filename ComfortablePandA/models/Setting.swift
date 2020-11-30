//
//  Setting.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/10/21.
//

import SwiftUI

class CPSetting {
    static let shared = CPSetting()
    
    @AppStorage("showDoneAssignments", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    var showDoneAssignments: Bool = true
    
    @AppStorage("autoUpdate", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    var autoUpdate: Bool = true
}
