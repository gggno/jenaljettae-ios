
//
//  ScreenHeader.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/16/26.
//

import SwiftUI

struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil
    var onAdd: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            HStack {
                Text(title)
                    .font(.system(.title, weight: .bold))
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                if let onAdd {
                    Button(action: onAdd) {
                        Image(AppIcon.add)
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(AppColor.textPrimary)
                            .frame(width: 48, height: 44, alignment: .trailing)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("항목 추가")
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.medium)
    }
}
