//
//  TypeFilter.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/20/26.
//

import SwiftUI

// MARK: - Filter Type

enum ItemTypeFilter: CaseIterable {
    case all
    case coupon
    case pass
    case subscription
    case schedule

    var title: String {
        switch self {
        case .all: return "전체"
        case .coupon: return "쿠폰"
        case .pass: return "이용권"
        case .subscription: return "구독"
        case .schedule: return "일정"
        }
    }
}

// MARK: - Type Filter

struct TypeFilter: View {
    let selectedType: ItemTypeFilter
    let onSelect: (ItemTypeFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xSmall) {
                ForEach(ItemTypeFilter.allCases, id: \.self) { type in
                    let isSelected = selectedType == type

                    Button {
                        onSelect(type)
                    } label: {
                        Text(type.title)
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? AppColor.onPrimary : AppColor.textSecondary)
                            .padding(.horizontal, AppSpacing.small)
                            .padding(.vertical, AppSpacing.xSmall)
                            .background(isSelected ? AppColor.primary : AppColor.inputSurface, in: RoundedRectangle(cornerRadius: 10))
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }
}
