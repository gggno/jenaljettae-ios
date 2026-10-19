
import SwiftUI

// MARK: - Content View

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - Home Tab

            TabPlaceholderView(
                title: "홈",
                description: "홈 화면을 개발할 예정입니다."
            )
            .tabItem {
                Image(AppIcon.home)
                    .renderingMode(.template)
                Text("홈")
            }
            .tag(0)

            // MARK: - Library Tab

            TabPlaceholderView(
                title: "보관함",
                description: "보관함 화면을 개발할 예정입니다."
            )
            .tabItem {
                Image(AppIcon.vault)
                    .renderingMode(.template)
                Text("보관함")
            }
            .tag(1)

            // MARK: - Settings Tab

            TabPlaceholderView(
                title: "설정",
                description: "설정 화면을 개발할 예정입니다."
            )
            .tabItem {
                Image(AppIcon.settings)
                    .renderingMode(.template)
                Text("설정")
            }
            .tag(2)
        }
        .tint(AppColor.primaryForeground)
    }
}

// MARK: - Temporary Tab Screen

// 실제 화면 구현 전까지 사용하는 임시 화면
private struct TabPlaceholderView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            Text(title)
                .font(AppTypography.screenTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text(description)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background.ignoresSafeArea())
    }
}

// MARK: - Light / Dark Preview

#Preview("Light") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
