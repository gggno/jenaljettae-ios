//
//  MainTabView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI
import SwiftData

// MARK: - Main Tab | 앱에서 사용할 탭 유형
private enum MainTab: Hashable {
    case home
    case library
    case settings
}

// MARK: - Main Tab View | 홈·보관함에 실제 SwiftData Repository 주입
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Home | 기존 홈 화면 유지
            NavigationStack {
                HomeView(repository: SwiftDataManagedItemRepository(modelContext: modelContext))
            }
            .tabItem {
                Image(AppIcon.home).renderingMode(.template)
                Text("홈")
            }
            .tag(MainTab.home)

            // MARK: - Library | Repository와 상세 이동용 NavigationStack 연결
            NavigationStack {
                LibraryView(repository: SwiftDataManagedItemRepository(modelContext: modelContext))
            }
            .tabItem {
                Image(AppIcon.vault).renderingMode(.template)
                Text("보관함")
            }
            .tag(MainTab.library)

            // MARK: - Settings | 설정 탭 유지
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

// MARK: - Preview | 메모리 저장소로 라이트·다크 모드 확인
#Preview("Light") {
    MainTabView()
        .modelContainer(for: ManagedItemEntity.self, inMemory: true)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MainTabView()
        .modelContainer(for: ManagedItemEntity.self, inMemory: true)
        .preferredColorScheme(.dark)
}
