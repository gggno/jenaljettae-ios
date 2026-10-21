//
//  RegistrationTypeSelectionView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI

// MARK: - Registration Type Selection

struct RegistrationTypeSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showsNextStepNotice = false
    @State private var selectedTypeName = ""
    @State private var showsCouponRegistrationMethod = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {

                // MARK: - Description

                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("무엇을 보관할까요?")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColor.textPrimary)

                    Text("유형에 맞는 날짜와 상태를 관리해요.")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                }

                // MARK: - Type Selection Cards

                VStack(spacing: AppSpacing.cardSpacing) {
                    
                    ItemCard(
                        title: "쿠폰·기프티콘",
                        subtitle: "상품 교환권, 할인 쿠폰",
                        iconName: "ic_jnt_coupon",
                        statusLabel: "",
                        mode: .typeSelection
                    ) {
                        showsCouponRegistrationMethod = true
                    }

                    typeCard(
                        title: "이용권",
                        subtitle: "기간제 구독권, 기간권",
                        iconName: "ic_jnt_pass"
                    )

                    typeCard(
                        title: "정기 구독",
                        subtitle: "매월·매년 반복되는 갱신",
                        iconName: "ic_jnt_subscription"
                    )

                    typeCard(
                        title: "예약",
                        subtitle: "식당, 병원, 미용실, 숙박",
                        iconName: "ic_jnt_reservation"
                    )
                }

                // MARK: - Type Notice

                HStack(alignment: .top, spacing: AppSpacing.xSmall) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(AppColor.primaryForeground)

                    Text("고정 기간은 이용권, 반복 갱신은 정기 구독으로 구분해요.")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(AppSpacing.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColor.primaryTint, in: RoundedRectangle(cornerRadius: AppRadius.card))
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.large)
            .padding(.bottom, AppSpacing.xLarge)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("유형 선택")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showsCouponRegistrationMethod) {
            CouponRegistrationMethodView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image("ic_jnt_close")
                }
                .tint(AppColor.primaryForeground)
                .accessibilityLabel("닫기")
            }
        }

        .alert("등록 화면 준비 중", isPresented: $showsNextStepNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("\(selectedTypeName) 등록 화면은 다음 단계에서 연결할 예정이에요.")
        }
    }

    // MARK: - Type Card

    private func typeCard(title: String, subtitle: String, iconName: String) -> some View {
        ItemCard(
            title: title,
            subtitle: subtitle,
            iconName: iconName,
            statusLabel: "",
            mode: .typeSelection
        ) {
            selectedTypeName = title
            showsNextStepNotice = true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegistrationTypeSelectionView()
    }
}

