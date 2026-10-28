//
//  JENALJETTAEApp.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/9/26.
//

import SwiftUI
import SwiftData

@main
struct JENALJETTAEApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: ManagedItemEntity.self)
    }
}
