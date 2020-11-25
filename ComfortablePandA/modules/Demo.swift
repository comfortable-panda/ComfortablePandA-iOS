//
//  Demo.swift
//  ComfortablePandA
//
//  Created by das08 on 2020/11/25.
//

import SwiftUI

class Demo {
    static let shared = Demo()
    
    @AppStorage("demo", store: UserDefaults(suiteName: "group.com.das08.ComfortablePandA"))
    private var isDemoMode: Data = Data()
    
    func setDemoFlag(demo: Bool) -> () {
        guard let save = try? JSONEncoder().encode(demo) else { return }
        self.isDemoMode = save
        print("saved demo mode settings")
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
