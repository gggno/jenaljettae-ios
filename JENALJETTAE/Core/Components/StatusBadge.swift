//
//  StatusBadge.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

// MARK: - Status Badge Tone
enum StatusBadgeTone {
    case attention
    case neutral
}

// MARK: - Status Badge
struct StatusBadge: View {
    let label: String
    var tone: StatusBadgeTone = .neutral

    // 상태에 따른 글자 색상
    private var foregroundColor: Color {
        tone == .attention ? AppColor.primaryForeground : AppColor.textSecondary
    }

    // 상태에 따른 배경 색상
    private var backgroundColor: Color {
        tone == .attention ? AppColor.primaryTint : AppColor.inputSurface
    }

    var body: some View {
        Text(label)
            .font(AppTypography.status)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.xxSmall)
            .background(backgroundColor, in: Capsule())
            .overlay {
                if tone == .neutral {
                    Capsule()
                        .strokeBorder(AppColor.border, lineWidth: 1)
                }
            }
    }
}

// MARK: - Preview Content
private struct StatusBadgePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(spacing: AppSpacing.small) {
                StatusBadge(label: "오늘", tone: .attention)
                StatusBadge(label: "D-3", tone: .attention)
            }

            HStack(spacing: AppSpacing.small) {
                StatusBadge(label: "완료")
                StatusBadge(label: "날짜 미등록")
            }
        }
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.background)
    }
}

#Preview("Light") {
    StatusBadgePreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    StatusBadgePreview()
        .preferredColorScheme(.dark)
}

