//
//  RegistrationTypeSelectionView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI

// MARK: - Registration Type Selection | 등록할 항목의 유형 선택 화면
struct RegistrationTypeSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - State | 안내창 및 쿠폰 등록 화면 이동 상태 관리
    @State private var showsNextStepNotice = false
    @State private var selectedTypeName = ""
    @State private var showsCouponRegistrationMethod = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {

                // MARK: - Description | 유형 선택 안내 문구
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("무엇을 보관할까요?")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppColor.textPrimary)

                    Text("유형에 맞는 날짜와 상태를 관리해요.")
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                }

                // MARK: - Type Selection Cards | 등록 유형별 선택 카드
                VStack(spacing: AppSpacing.cardSpacing) {
                    // 쿠폰 선택 시 등록 방법 화면으로 이동
                    ItemCard(
                        title: "쿠폰·기프티콘",
                        subtitle: "상품 교환권, 할인 쿠폰",
                        iconName: "ic_jnt_coupon",
                        statusLabel: "",
                        mode: .typeSelection
                    ) {
                        showsCouponRegistrationMethod = true
                    }

                    // TODO: 이용권 등록 화면 연결
                    typeCard(
                        title: "이용권",
                        subtitle: "기간제 구독권, 기간권",
                        iconName: "ic_jnt_pass"
                    )

                    // TODO: 정기 구독 등록 화면 연결
                    typeCard(
                        title: "정기 구독",
                        subtitle: "매월·매년 반복되는 갱신",
                        iconName: "ic_jnt_subscription"
                    )

                    // TODO: 일정 등록 화면 연결
                    typeCard(
                        title: "일정",
                        subtitle: "식당, 병원, 미용실, 숙박",
                        iconName: "ic_jnt_schedule"
                    )
                }

                // MARK: - Type Notice | 이용권과 정기 구독의 차이 안내
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

        // MARK: - Navigation | 쿠폰 등록 방법 화면으로 이동
        .navigationDestination(isPresented: $showsCouponRegistrationMethod) {
            CouponRegistrationMethodView()
        }

        // MARK: - Toolbar | X 버튼 클릭 시 등록 화면 닫기
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("ic_jnt_close")
                }
                .tint(AppColor.primaryForeground)
                .accessibilityLabel("닫기")
            }
        }

        // MARK: - Alert | 미구현 등록 유형 선택 시 안내창 표시
        .alert("등록 화면 준비 중", isPresented: $showsNextStepNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("\(selectedTypeName) 등록 화면은 다음 단계에서 연결할 예정이에요.")
        }
    }

    // MARK: - Type Card | 미구현 유형의 공통 카드 생성 및 안내창 표시
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

// MARK: - Preview | 유형 선택 화면 미리보기
#Preview {
    NavigationStack {
        RegistrationTypeSelectionView()
    }
}
