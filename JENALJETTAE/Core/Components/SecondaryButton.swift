//
//  SecondaryButton.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//


import SwiftUI

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(AppTypography.button)
                .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.disabledText)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .padding(.horizontal, AppSpacing.medium)
        }
        .buttonStyle(SecondaryButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

// MARK: - Button Style

private struct SecondaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor: Color

        // 활성화 여부와 눌림 상태에 따른 배경색
        if !isEnabled {
            backgroundColor = AppColor.disabledSurface
        } else if configuration.isPressed {
            backgroundColor = AppColor.secondaryPressed
        } else {
            backgroundColor = AppColor.card
        }

        return configuration.label
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: AppRadius.button))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.button)
                    .strokeBorder(isEnabled ? AppColor.border : AppColor.disabledSurface, lineWidth: 1)
            }
    }
}

// MARK: - Preview Content

private struct SecondaryButtonPreview: View {
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            PrimaryButton(title: "쿠폰 저장") {}
            SecondaryButton(title: "취소") {}
            SecondaryButton(title: "다른 사진 선택") {}
            SecondaryButton(title: "비활성화", isEnabled: false) {}
        }
        .padding(AppSpacing.large)
        .background(AppColor.background)
    }
}

// MARK: - Light / Dark Preview

#Preview("Light") {
    SecondaryButtonPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    SecondaryButtonPreview()
        .preferredColorScheme(.dark)
}
