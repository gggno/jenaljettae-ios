//
//  PrimaryButton.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/12/26.
//

import SwiftUI

enum PrimaryButtonRole {
    case normal
    case destructive
}

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    var role: PrimaryButtonRole = .normal
    let onTap: () -> Void

    private var isVisuallyDisabled: Bool { !isEnabled && !isLoading }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.xSmall) {
                if isLoading {
                    ProgressView()
                        .tint(AppColor.onPrimary)
                }

                Text(title)
                    .font(AppTypography.button)
            }
            .foregroundStyle(isVisuallyDisabled ? AppColor.disabledText : AppColor.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .padding(.horizontal, AppSpacing.medium)
        }
        .buttonStyle(PrimaryButtonStyle(isVisuallyDisabled: isVisuallyDisabled, role: role))
        .disabled(!isEnabled || isLoading)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    let isVisuallyDisabled: Bool
    let role: PrimaryButtonRole

    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color

        if isVisuallyDisabled {
            backgroundColor = AppColor.disabledSurface
        } else if role == .destructive {
            backgroundColor = AppColor.destructiveBackground
        } else {
            backgroundColor = configuration.isPressed ? AppColor.primaryPressed : AppColor.primary
        }

        return configuration.label
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: AppRadius.button))
    }
}

#Preview("Light") {
    VStack(spacing: AppSpacing.small) {
        PrimaryButton(title: "쿠폰 저장") {}
        PrimaryButton(title: "저장 중...", isLoading: true) {}
        PrimaryButton(title: "쿠폰 저장", isEnabled: false) {}
        PrimaryButton(title: "삭제하기", role: .destructive) {}
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    VStack(spacing: AppSpacing.small) {
        PrimaryButton(title: "쿠폰 저장") {}
        PrimaryButton(title: "저장 중...", isLoading: true) {}
        PrimaryButton(title: "쿠폰 저장", isEnabled: false) {}
        PrimaryButton(title: "삭제하기", role: .destructive) {}
    }
    .padding(AppSpacing.large)
    .background(AppColor.background)
    .preferredColorScheme(.dark)
}
