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

// MARK: - Main Tab View | 화면 구성과 실제 SwiftData Repository 연결
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Home | 실제 SwiftData Repository를 홈 화면에 주입
            NavigationStack {
                HomeView(repository: SwiftDataManagedItemRepository(modelContext: modelContext))
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
        
#if DEBUG
.task {
    do {
        let repository = SwiftDataManagedItemRepository(modelContext: modelContext)
        let items = try repository.fetchItems()

        // MARK: - Debug | SwiftData에 저장된 전체 데이터 출력
        for item in items {
            print("📦 ID: \(item.id)")
            print("유형: \(item.type.rawValue)")
            print("제목: \(item.title)")
            print("브랜드: \(item.detail)")
            print("쿠폰 번호: \(item.couponNumber)")
            print("메모: \(item.memo)")
            print("시작일: \(item.startDate)")
            print("종료일: \(String(describing: item.endDate))\n")
            
        }

        print("✅ 저장된 전체 데이터: \(items.count)개")
    } catch {
        print("❌ 데이터 조회 실패: \(error)")
    }
}
#endif

    }
}

// MARK: - Preview | 저장소를 메모리에 생성해 라이트·다크 모드 확인
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
