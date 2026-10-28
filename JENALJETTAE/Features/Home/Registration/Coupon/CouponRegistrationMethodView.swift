//
//  CouponRegistrationMethodView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI

// MARK: - Coupon Registration Method | 쿠폰 등록 방법 선택 화면
struct CouponRegistrationMethodView: View {
    @State private var showsNextStepNotice = false
    @State private var selectedMethodName = ""
    @State private var showsManualEntry = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                // MARK: - Description | 쿠폰 등록 방법 안내
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("쿠폰·기프티콘")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.primaryForeground)

                    Text("어떻게 등록할까요?")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColor.textPrimary)

                    Text("이미지 속 글자를 AI로 읽어 입력을 도와줘요.")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                }

                // MARK: - Registration Buttons | AI 인식 및 직접 입력 선택
                VStack(spacing: AppSpacing.small) {
                    Button {
                        selectedMethodName = "AI로 쿠폰 읽기"
                        showsNextStepNotice = true
                    } label: {
                        Text("AI로 쿠폰 읽기")
                            .font(.headline)
                            .foregroundStyle(AppColor.onPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppRadius.card))
                    }
                    .buttonStyle(.plain)

                    Button {
                        showsManualEntry = true
                    } label: {
                        Text("직접 입력하기")
                            .font(.headline)
                            .foregroundStyle(AppColor.primaryForeground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.card))
                            .overlay {
                                RoundedRectangle(cornerRadius: AppRadius.card)
                                    .strokeBorder(AppColor.border, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Sample Coupon | 쿠폰 등록 예시 표시
                VStack(spacing: AppSpacing.xSmall) {
                    Image("ic_jnt_coupon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColor.primaryForeground)
                        .frame(width: 32, height: 32)

                    Text("아메리카노 교환권")
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("COUPON SAMPLE")
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(AppColor.primaryTint, in: RoundedRectangle(cornerRadius: AppRadius.card))

                Text("사진 한 장을 선택한 뒤 인식한 내용을 확인하고 수정할 수 있어요.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.large)
            .padding(.bottom, AppSpacing.xLarge)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("쿠폰 등록 방법")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Manual Entry | 직접 입력 화면으로 이동
        .navigationDestination(isPresented: $showsManualEntry) {
            CouponManualEntryView()
        }
        .tint(AppColor.primaryForeground)

        // MARK: - Alert | 미구현 AI 등록 기능 안내
        .alert("등록 기능 준비 중", isPresented: $showsNextStepNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("\(selectedMethodName) 기능은 다음 단계에서 연결할 예정이에요.")
        }
    }
}
