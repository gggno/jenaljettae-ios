//
//  CouponManualEntryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI
import UIKit

// MARK: - Coupon Manual Entry

struct CouponManualEntryView: View {
    @State private var couponTitle = ""
    @State private var brand = ""
    @State private var couponNumber = ""
    @State private var memo = ""

    @State private var expiryDate: Date?
    @State private var pickerDate = Date()

    @State private var showsDatePicker = false
    @State private var showsMemoEditor = false
    @State private var showsSaveNotice = false

    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isMemoFocused: Bool

    private var canSave: Bool {
        !couponTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && expiryDate != nil
    }

    private var expiryDateText: String {
        guard let expiryDate else { return "날짜 선택" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: expiryDate)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Input Content

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {

                        // MARK: - Product Name

                        CouponEntryTextField(
                            label: "상품명 *",
                            placeholder: "상품명을 입력해주세요.",
                            text: $couponTitle
                        )

                        // MARK: - Brand

                        CouponEntryTextField(
                            label: "브랜드 (선택)",
                            placeholder: "브랜드를 입력해주세요.",
                            text: $brand
                        )

                        // MARK: - Expiry Date

                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text("만료일 *")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textPrimary)

                            Button {
                                hideKeyboard()
                                pickerDate = expiryDate ?? Date()

                                withAnimation {
                                    showsDatePicker.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(expiryDateText)
                                        .foregroundStyle(expiryDate == nil ? AppColor.textSecondary : AppColor.textPrimary)

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

                            // MARK: - Inline Date Picker

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

                                        Spacer()

                                        Button("적용") {
                                            expiryDate = Calendar.current.startOfDay(for: pickerDate)

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

                        // MARK: - Coupon Number

                        CouponEntryTextField(
                            label: "쿠폰 번호 (선택)",
                            placeholder: "쿠폰 번호를 입력해주세요.",
                            text: $couponNumber
                        )

                        // MARK: - Memo

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
                                TextEditor(text: $memo)
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

                        // MARK: - Required Fields Notice

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

                // MARK: - Memo Auto Scroll

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
                .onChange(of: memo) { _, newMemo in
                    guard isMemoFocused && newMemo.hasSuffix("\n") else { return }

                    withAnimation {
                        proxy.scrollTo("memoEditor", anchor: .top)
                    }
                }
            }

            // MARK: - Fixed Save Button

            Button {
                hideKeyboard()
                showsSaveNotice = true
            } label: {
                Text("쿠폰 저장")
                    .font(.headline)
                    .foregroundStyle(canSave ? AppColor.onPrimary : AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        canSave ? AppColor.primary : AppColor.inputSurface,
                        in: RoundedRectangle(cornerRadius: AppRadius.card)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.small)
            .background(AppColor.background)
        }
        .background(AppColor.background.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle("쿠폰 등록")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Keyboard Height For Scroll Only

        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = max(0, UIScreen.main.bounds.maxY - frame.minY)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }

        // MARK: - Save Notice

        .alert("저장 기능 준비 중", isPresented: $showsSaveNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("입력 화면 확인용 단계예요. 실제 쿠폰 저장은 다음 단계에서 연결할 예정이에요.")
        }
    }
}

// MARK: - Coupon Entry Text Field

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

// MARK: - Preview

#Preview {
    NavigationStack {
        CouponManualEntryView()
    }
}
