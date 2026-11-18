//
//  ThemeSettingsView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import SwiftUI

// MARK: - Theme Settings View | 화면 테마 선택
struct ThemeSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                Text("앱에서 사용할 화면 스타일을 선택해 주세요.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)

                VStack(spacing: AppSpacing.small) {
                    ForEach(AppThemeMode.allCases) { theme in
                        Button {
                            viewModel.selectTheme(theme)
                        } label: {
                            themeRow(theme)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.large)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("화면 테마")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Theme Row | 테마 선택 항목
    private func themeRow(_ theme: AppThemeMode) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(theme.icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(AppColor.textPrimary)

            VStack(alignment: .leading, spacing: 4) {
                Text(theme.title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textPrimary)

                Text(theme.description)
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: 8)

            if viewModel.selectedTheme == theme {
                Image(AppIcon.check)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(AppColor.primaryForeground)
            }
        }
        .padding(AppSpacing.small)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(
            AppColor.textPrimary.opacity(0.045),
            in: RoundedRectangle(cornerRadius: AppRadius.largeCard)
        )
        .contentShape(Rectangle())
    }
}
