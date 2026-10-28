//
//  CouponManualEntryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI
import UIKit

// MARK: - Coupon Manual Entry | 쿠폰 직접 입력 및 저장 화면
struct CouponManualEntryView: View {
    @Environment(\.saveCouponUseCase) private var saveCouponUseCase
    @Environment(\.onCouponSaved) private var onCouponSaved

    @StateObject private var viewModel = CouponRegistrationViewModel()

    @State private var pickerDate = Date()
    @State private var showsDatePicker = false
    @State private var showsMemoEditor = false
    @State private var keyboardHeight: CGFloat = 0

    @FocusState private var isMemoFocused: Bool

    // MARK: - Save Validation | 필수 입력값과 Environment 주입 여부 확인
    private var canSubmit: Bool {
        viewModel.canSave && saveCouponUseCase != nil && onCouponSaved != nil
    }

    // MARK: - Expiry Date Text | 선택 날짜를 화면 표시용 문자열로 변환
    private var expiryDateText: String {
        guard let expiryDate = viewModel.expiryDate else { return "날짜 선택" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: expiryDate)
    }

    // MARK: - Hide Keyboard | 현재 입력 중인 키보드 닫기
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Input Content | 쿠폰 정보 입력 영역
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {

                        // MARK: - Product Name | 상품명 필수 입력
                        CouponEntryTextField(
                            label: "상품명 *",
                            placeholder: "상품명을 입력해주세요.",
                            text: $viewModel.couponTitle
                        )

                        // MARK: - Brand | 브랜드 선택 입력
                        CouponEntryTextField(
                            label: "브랜드 (선택)",
                            placeholder: "브랜드를 입력해주세요.",
                            text: $viewModel.brand
                        )

                        // MARK: - Expiry Date | 만료일 필수 선택
                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text("만료일 *")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textPrimary)

                            Button {
                                hideKeyboard()
                                pickerDate = viewModel.expiryDate ?? Date()

                                withAnimation {
                                    showsDatePicker.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(expiryDateText)
                                        .foregroundStyle(viewModel.expiryDate == nil ? AppColor.textSecondary : AppColor.textPrimary)

                                    Spacer()

                                    Image(systemName: "calendar")
                                        .foregroundStyle(AppColor.primaryForeground)
                                }
                                .font(.body)
                                .padding(.horizontal, AppSpacing.small)
                                .frame(height: 50)
                                .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                            }
                            .buttonStyle(.plain)

                            // MARK: - Inline Date Picker | 날짜 선택 및 적용
                            if showsDatePicker {
                                VStack(spacing: AppSpacing.small) {
                                    DatePicker(
                                        "만료일",
                                        selection: $pickerDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .environment(\.locale, Locale(identifier: "ko_KR"))
                                    .frame(height: 216)

                                    HStack {
                                        Button("취소") {
                                            withAnimation {
                                                showsDatePicker = false
                                            }
                                        }
                                        .foregroundStyle(AppColor.textSecondary)

                                        if viewModel.expiryDate != nil {
                                            Button("날짜 지우기") {
                                                viewModel.expiryDate = nil

                                                withAnimation {
                                                    showsDatePicker = false
                                                }
                                            }
                                            .foregroundStyle(AppColor.textSecondary)
                                        }

                                        Spacer()

                                        Button("적용") {
                                            viewModel.expiryDate = Calendar.current.startOfDay(for: pickerDate)

                                            withAnimation {
                                                showsDatePicker = false
                                            }
                                        }
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppColor.primaryForeground)
                                    }
                                }
                                .padding(AppSpacing.medium)
                                .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.card))
                            }
                        }

                        // MARK: - Coupon Number | 쿠폰 번호 선택 입력
                        CouponEntryTextField(
                            label: "쿠폰 번호 (선택)",
                            placeholder: "쿠폰 번호를 입력해주세요.",
                            text: $viewModel.couponNumber
                        )

                        // MARK: - Memo | 메모 입력 영역 펼치기
                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Button {
                                withAnimation {
                                    showsMemoEditor.toggle()
                                }

                                if !showsMemoEditor {
                                    hideKeyboard()
                                }
                            } label: {
                                HStack {
                                    Text("메모 추가 (선택)")
                                        .foregroundStyle(AppColor.textPrimary)

                                    Spacer()

                                    Image(systemName: showsMemoEditor ? "chevron.up" : "chevron.down")
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                                .font(.subheadline)
                                .padding(AppSpacing.medium)
                                .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                            }
                            .buttonStyle(.plain)

                            if showsMemoEditor {
                                TextEditor(text: $viewModel.memo)
                                    .font(.body)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .focused($isMemoFocused)
                                    .scrollContentBackground(.hidden)
                                    .frame(height: 120)
                                    .padding(AppSpacing.xSmall)
                                    .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                                    .id("memoEditor")
                                    .onAppear {
                                        isMemoFocused = true
                                    }
                            }
                        }

                        // MARK: - Required Fields Notice | 필수 입력 항목 안내
                        Text("상품명과 만료일은 필수 입력 항목이에요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.large)
                    .padding(.bottom, AppSpacing.xLarge + 80 + keyboardHeight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                hideKeyboard()
                            }
                    }
                }
                .scrollDismissesKeyboard(.never)
                .background {
                    AppColor.background
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                        }
                }

                // MARK: - Memo Auto Scroll | 메모 입력 시 스크롤 위치 조정
                .onChange(of: isMemoFocused) { _, focused in
                    guard focused else { return }

                    withAnimation {
                        proxy.scrollTo("memoEditor", anchor: .top)
                    }
                }
                .onChange(of: keyboardHeight) { _, height in
                    guard height > 0 && isMemoFocused else { return }

                    withAnimation {
                        proxy.scrollTo("memoEditor", anchor: .top)
                    }
                }
                .onChange(of: viewModel.memo) { _, newMemo in
                    guard isMemoFocused && newMemo.hasSuffix("\n") else { return }

                    withAnimation {
                        proxy.scrollTo("memoEditor", anchor: .top)
                    }
                }
            }

            // MARK: - Save Button | Environment의 UseCase로 저장 후 완료 알림
            Button {
                hideKeyboard()

                guard let saveCouponUseCase, let onCouponSaved else { return }

                if let savedItem = viewModel.saveCoupon(using: saveCouponUseCase) {
                    onCouponSaved(savedItem)
                }
            } label: {
                Text(viewModel.isSaving ? "저장 중..." : "쿠폰 저장")
                    .font(.headline)
                    .foregroundStyle(canSubmit ? AppColor.onPrimary : AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        canSubmit ? AppColor.primary : AppColor.inputSurface,
                        in: RoundedRectangle(cornerRadius: AppRadius.card)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canSubmit)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.small)
            .background(AppColor.background)
        }
        .background(AppColor.background.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle("쿠폰 등록")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Keyboard Height | 메모 입력 시 스크롤 여백 계산
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = max(0, UIScreen.main.bounds.maxY - frame.minY)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }

        // MARK: - Save Error | 저장 실패 시 오류 Alert 표시
        .alert("쿠폰 저장 실패", isPresented: $viewModel.showsSaveError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage)
        }
    }
}

// MARK: - Coupon Entry Text Field | 쿠폰 정보 공통 입력 UI
private struct CouponEntryTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textPrimary)

            TextField(placeholder, text: $text)
                .font(.body)
                .foregroundStyle(AppColor.textPrimary)
                .focused($isFocused)
                .padding(.horizontal, AppSpacing.small)
                .frame(height: 50)
                .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                .overlay {
                    RoundedRectangle(cornerRadius: AppRadius.input)
                        .strokeBorder(isFocused ? AppColor.primary : AppColor.border, lineWidth: 1)
                }
                .accessibilityLabel(label)
        }
    }
}

// MARK: - Preview | 테스트용 UseCase 및 저장 완료 함수 주입
#Preview {
    NavigationStack {
        CouponManualEntryView()
    }
    .environment(\.saveCouponUseCase, SaveCouponUseCase(repository: SampleManagedItemRepository()))
    .environment(\.onCouponSaved, { _ in })
}
