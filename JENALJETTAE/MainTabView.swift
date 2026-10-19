//
//  MainTabView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

// MARK: - Main Tab

private enum MainTab: Hashable {
    case home
    case library
    case settings
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - Home

            HomeView()
                .tabItem {
                    Image(AppIcon.home)
                        .renderingMode(.template)
                    Text("홈")
                }
                .tag(MainTab.home)

            // MARK: - Library

            LibraryView()
                .tabItem {
                    Image(AppIcon.vault)
                        .renderingMode(.template)
                    Text("보관함")
                }
                .tag(MainTab.library)

            // MARK: - Settings

            SettingsView()
                .tabItem {
                    Image(AppIcon.settings)
                        .renderingMode(.template)
                    Text("설정")
                }
                .tag(MainTab.settings)
        }
        .tint(AppColor.primaryForeground)
    }
}

// MARK: - Light / Dark Preview

#Preview("Light") {
    MainTabView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MainTabView()
        .preferredColorScheme(.dark)
}
