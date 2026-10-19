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
                        HStack(spacing: AppSpacing.xSmall) {
                            Image(AppIcon.add)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text("추가")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(AppColor.onPrimary)
                        .padding(.horizontal, AppSpacing.small)
                        .frame(minHeight: 48)
                        .background(AppColor.primary, in: RoundedRectangle(cornerRadius: 14))
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
        .padding(.bottom, AppSpacing.large)
    }
}
