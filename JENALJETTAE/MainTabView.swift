//
//  MainTabView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

// MARK: - Main Tab | 앱에서 사용할 탭 유형
private enum MainTab: Hashable {
    case home
    case library
    case settings
}

// MARK: - Main Tab View | 화면 구성과 Repository 실제 구현 연결
struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Home | 앱의 조립 지점에서 테스트용 Repository 주입
            NavigationStack {
                HomeView(repository: SampleManagedItemRepository())
            }
            .tabItem {
                Image(AppIcon.home).renderingMode(.template)
                Text("홈")
            }
            .tag(MainTab.home)

            // MARK: - Library | 보관함 탭
            LibraryView()
                .tabItem {
                    Image(AppIcon.vault).renderingMode(.template)
                    Text("보관함")
                }
                .tag(MainTab.library)

            // MARK: - Settings | 설정 탭
            SettingsView()
                .tabItem {
                    Image(AppIcon.settings).renderingMode(.template)
                    Text("설정")
                }
                .tag(MainTab.settings)
        }
        .tint(AppColor.primaryForeground)
    }
}

// MARK: - Preview | 라이트·다크 모드 확인
#Preview("Light") {
    MainTabView().preferredColorScheme(.light)
}

#Preview("Dark") {
    MainTabView().preferredColorScheme(.dark)
}
