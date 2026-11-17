//
//  LibrarySummaryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/17/26.
//

import SwiftUI

// MARK: - Library Summary View | 보관 현황 선택 카드
struct LibrarySummaryView: View {
    let totalCount: Int
    let activeCount: Int
    let historyCount: Int
    let selectedScope: LibraryScope
    let onSelect: (LibraryScope) -> Void

    var body: some View {
        HStack(spacing: 5) {
            summaryButton(.all, count: totalCount)
            summaryButton(.active, count: activeCount)
            summaryButton(.history, count: historyCount)
        }
        .padding(6)
        .background(AppColor.primaryTint, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Summary Button | 선택 배경·테두리·글자 색 전환
    private func summaryButton(_ scope: LibraryScope, count: Int) -> some View {
        let isSelected = selectedScope == scope
        return Button { onSelect(scope) } label: {
            VStack(spacing: AppSpacing.xSmall) {
                Text("\(count)")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text(scope.title)
                    .font(AppTypography.caption.weight(isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? AppColor.primaryForeground : AppColor.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 86)
            .background(isSelected ? AppColor.card : Color.clear, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? AppColor.primary.opacity(0.32) : Color.clear, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(scope.title), \(count)개")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeInOut(duration: 0.2), value: selectedScope)
        .animation(.easeInOut(duration: 0.2), value: count)
    }
}

