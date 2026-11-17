//
//  LibraryItemRow.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import SwiftUI

// MARK: - Library Item Row | 보관함 전용 간결한 목록 행
struct LibraryItemRow: View {
    let item: ManagedItem
    let subtitle: String
    let status: String
    let isArchived: Bool

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(isArchived ? AppColor.disabledText : AppColor.primaryForeground)
                .frame(width: 21, height: 21)
                .frame(width: 44, height: 44)
                .background(
                    isArchived ? AppColor.surface : AppColor.primaryTint,
                    in: RoundedRectangle(cornerRadius: 12)
                )

            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                Text(item.title)
                    .font(AppTypography.itemTitle)
                    .foregroundStyle(isArchived ? AppColor.textSecondary : AppColor.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(status)
                .font(AppTypography.status)
                .foregroundStyle(isArchived ? AppColor.disabledText : AppColor.primaryForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColor.disabledText)
        }
        .padding(.vertical, AppSpacing.small)
        .contentShape(Rectangle())
    }

    // MARK: - Item Icon | 기존 Assets 아이콘 재사용
    private var iconName: String {
        switch item.type {
        case .coupon: return "ic_jnt_coupon"
        case .pass: return "ic_jnt_pass"
        case .subscription: return "ic_jnt_subscription"
        case .schedule: return "ic_jnt_schedule"
        }
    }
}
