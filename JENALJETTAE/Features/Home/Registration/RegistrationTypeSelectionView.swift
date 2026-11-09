//
//  RegistrationTypeSelectionView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI

// MARK: - Registration Type Selection | 등록할 항목 유형 선택 화면
struct RegistrationTypeSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showsCouponRegistrationMethod = false
    @State private var showsPassManualEntry = false
    @State private var showsSubscriptionManualEntry = false
    @State private var showsScheduleManualEntry = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {

            // MARK: - Description | 등록 유형 선택 안내
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text("무엇을 보관할까요?")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColor.textPrimary)

                Text("유형에 맞는 날짜와 상태를 관리해요.")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }

            // MARK: - Type Selection Cards | 유형별 등록 화면으로 이동
            VStack(spacing: AppSpacing.cardSpacing) {

                // MARK: - Coupon | 쿠폰 등록
                ItemCard(
                    title: "쿠폰·기프티콘",
                    subtitle: "상품 교환권, 할인 쿠폰",
                    iconName: "ic_jnt_coupon",
                    statusLabel: "",
                    mode: .typeSelection
                ) {
                    showsCouponRegistrationMethod = true
                }

                // MARK: - Pass | 이용권 등록
                ItemCard(
                    title: "이용권",
                    subtitle: "기간제 구독권, 기간권",
                    iconName: "ic_jnt_pass",
                    statusLabel: "",
                    mode: .typeSelection
                ) {
                    showsPassManualEntry = true
                }

                // MARK: - Subscription | 정기 구독 등록
                ItemCard(
                    title: "정기 구독",
                    subtitle: "매월·매년 반복되는 갱신",
                    iconName: "ic_jnt_subscription",
                    statusLabel: "",
                    mode: .typeSelection
                ) {
                    showsSubscriptionManualEntry = true
                }

                // MARK: - Schedule | 일정 등록
                ItemCard(
                    title: "일정",
                    subtitle: "식당, 병원, 미용실, 숙박",
                    iconName: "ic_jnt_schedule",
                    statusLabel: "",
                    mode: .typeSelection
                ) {
                    showsScheduleManualEntry = true
                }
            }

            // MARK: - Type Notice | 이용권과 정기 구독의 차이
            HStack(alignment: .top, spacing: AppSpacing.xSmall) {
                Image(systemName: "info.circle")
                    .foregroundStyle(AppColor.primaryForeground)

                Text("고정 기간은 이용권, 반복 갱신은 정기 구독으로 구분해요.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                AppColor.primaryTint,
                in: RoundedRectangle(cornerRadius: AppRadius.card)
            )

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.large)
        .padding(.bottom, AppSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("유형 선택")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Coupon Navigation | 쿠폰
        .navigationDestination(isPresented: $showsCouponRegistrationMethod) {
            CouponRegistrationMethodView()
        }

        // MARK: - Pass Navigation | 이용권
        .navigationDestination(isPresented: $showsPassManualEntry) {
            PassManualEntryView()
        }

        // MARK: - Subscription Navigation | 정기 구독
        .navigationDestination(isPresented: $showsSubscriptionManualEntry) {
            SubscriptionManualEntryView()
        }

        // MARK: - Schedule Navigation | 일정
        .navigationDestination(isPresented: $showsScheduleManualEntry) {
            ScheduleManualEntryView()
        }

        // MARK: - Toolbar | 닫기 버튼
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image("ic_jnt_close")
                }
                .tint(AppColor.primaryForeground)
                .accessibilityLabel("닫기")
            }
        }
    }
}
