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

// MARK: - Main Tab View | 각 화면에 Repository 주입 및 앱 전체 테마 적용
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(UserDefaultsThemeRepository.storageKey) private var selectedTheme = AppThemeMode.system.rawValue
    @State private var selectedTab: MainTab = .home

    private var appColorScheme: ColorScheme? {
        (AppThemeMode(rawValue: selectedTheme) ?? .system).colorScheme
    }

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

            // MARK: - Library | Repository 및 상세 화면 이동
            NavigationStack {
                LibraryView(repository: SwiftDataManagedItemRepository(modelContext: modelContext))
            }
            .tabItem {
                Image(AppIcon.vault).renderingMode(.template)
                Text("보관함")
            }
            .tag(MainTab.library)

            // MARK: - Settings | Repository로 설정 화면 생성
            NavigationStack {
                SettingsView(
                    themeRepository: UserDefaultsThemeRepository(),
                    notificationPermissionRepository: SystemNotificationPermissionRepository()
                )
            }
            .tabItem {
                Image(AppIcon.settings).renderingMode(.template)
                Text("설정")
            }
            .tag(MainTab.settings)
        }
        .tint(AppColor.primaryForeground)
        .preferredColorScheme(appColorScheme)
    }
}

// MARK: - Preview | 앱 메인 화면 미리보기
#Preview {
    MainTabView()
        .modelContainer(for: ManagedItemEntity.self, inMemory: true)
}
