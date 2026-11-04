//
//  CouponAnalysisLoadingView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/3/26.
//

import SwiftUI

// MARK: - Coupon Analysis Loading | 실제 분석 요청 동안 표시하는 펄스 오버레이
struct CouponAnalysisLoadingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // MARK: - Backdrop | 테마 배경색으로 쿠폰 이미지를 옅게 가려 로딩 내용 강조
            AppColor.background.opacity(0.9).ignoresSafeArea()

            VStack(spacing: AppSpacing.large) {
                ZStack {
                    // MARK: - Waves | 두 원이 0.9초 간격으로 확산되며 사라짐
                    if !reduceMotion {
                        ForEach(0..<2) { index in
                            Circle()
                                .stroke(AppColor.primaryForeground, lineWidth: 1.5)
                                .frame(width: 88, height: 88)
                                .scaleEffect(isAnimating ? 1.65 : 0.85)
                                .opacity(isAnimating ? 0 : 0.36)
                                .animation(.easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(Double(index) * 0.9), value: isAnimating)
                        }
                    }

                    Circle().fill(AppColor.primaryTint).frame(width: 80, height: 80)

                    // MARK: - Pulse | sparkles 아이콘을 부드럽게 확대·축소
                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(AppColor.primaryForeground)
                        .scaleEffect(reduceMotion ? 1 : (isAnimating ? 1.08 : 0.92))
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isAnimating)
                }
                .frame(width: 160, height: 160)
                .accessibilityHidden(true)

                VStack(spacing: AppSpacing.xSmall) {
                    Text("AI가 쿠폰을 분석하고 있어요")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("쿠폰 정보를 확인하고 있어요.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.xLarge)
            .frame(maxWidth: 340)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .accessibilityAddTraits(.isModal)
        .onChange(of: reduceMotion, initial: true) { _, reduceMotion in isAnimating = !reduceMotion }
    }
}

// MARK: - Light Preview | 라이트 모드 로딩 미리보기
#Preview("Light") {
    CouponAnalysisLoadingView().preferredColorScheme(.light)
}

// MARK: - Dark Preview | 다크 모드 로딩 미리보기
#Preview("Dark") {
    CouponAnalysisLoadingView().preferredColorScheme(.dark)
}
