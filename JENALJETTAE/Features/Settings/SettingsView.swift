//
//  SettingsView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

// MARK: - Settings View | 설정 메인 화면
struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: SettingsViewModel

    // MARK: - Dependency Injection | Repository로 설정 ViewModel 생성
    @MainActor
    init(
        themeRepository: any ThemeRepository,
        notificationPermissionRepository: any NotificationPermissionRepository
    ) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            themeRepository: themeRepository,
            notificationPermissionRepository: notificationPermissionRepository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {

                // MARK: - Notification | 알림 설정
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("알림")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textPrimary)

                    NavigationLink {
                        SettingsPlaceholderView(title: "알림 설정")
                    } label: {
                        SettingsMenuRow(
                            icon: AppIcon.bell,
                            title: "알림 설정",
                            value: viewModel.notificationStatusText
                        )
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Appearance | 화면 테마 설정
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("화면")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textPrimary)

                    NavigationLink {
                        ThemeSettingsView(viewModel: viewModel)
                    } label: {
                        SettingsMenuRow(
                            icon: AppIcon.theme,
                            title: "화면 테마",
                            value: viewModel.selectedTheme.title
                        )
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Application | 앱 정보 표시
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("앱")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textPrimary)

                    SettingsMenuRow(
                        icon: AppIcon.info,
                        title: "앱 정보",
                        value: viewModel.appVersion,
                        showsChevron: false
                    )
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, 16)
            .padding(.bottom, AppSpacing.xLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background.ignoresSafeArea())
        .modifier(SettingsScrollEdgeStyle())
        .navigationTitle("설정")
        .modifier(SettingsNavigationTitleStyle())
        .task {
            await viewModel.refreshNotificationStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await viewModel.refreshNotificationStatus() }
            }
        }
    }
}

// MARK: - Settings Menu Row | 설정 메뉴 공통 UI
private struct SettingsMenuRow: View {
    let icon: String
    let title: String
    let value: String
    var showsChevron: Bool = true

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundStyle(AppColor.textPrimary)

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textPrimary)

            Spacer(minLength: 8)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)

            if showsChevron {
                Image("ic_jnt_chevron_right")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(AppSpacing.small)
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(
            AppColor.textPrimary.opacity(0.045),
            in: RoundedRectangle(cornerRadius: AppRadius.largeCard)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Settings Placeholder | 알림 설정 임시 화면
private struct SettingsPlaceholderView: View {
    let title: String

    var body: some View {
        VStack {
            Text("설정 화면 개발 예정")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Navigation Title Style | 홈과 동일한 제목 표시 방식
private struct SettingsNavigationTitleStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.toolbarTitleDisplayMode(.inlineLarge) }
        else { content.navigationBarTitleDisplayMode(.large) }
    }
}

// MARK: - Scroll Edge Style | iOS 26 이상 상단 스크롤 효과 제거
private struct SettingsScrollEdgeStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.scrollEdgeEffectHidden(true, for: .top) }
        else { content }
    }
}
