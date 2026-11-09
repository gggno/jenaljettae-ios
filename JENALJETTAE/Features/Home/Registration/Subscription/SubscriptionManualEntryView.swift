//
//  SubscriptionManualEntryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import SwiftUI
import PhotosUI
import UIKit
// MARK: - Subscription Manual Entry | 정기 구독 직접 등록 화면
struct SubscriptionManualEntryView: View {
    @Environment(\.saveSubscriptionUseCase) private var saveSubscriptionUseCase
    @Environment(\.onSubscriptionSaved) private var onSubscriptionSaved
    @StateObject private var viewModel = SubscriptionRegistrationViewModel()
    // MARK: - Date State | 구독 시작일 선택
    @State private var showsDatePicker = false
    @State private var pickerDate = Date()
    // MARK: - Image State | 공통 이미지 UI에서 사진 선택
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var showsPhotoLoadError = false
    // MARK: - Memo State | 메모 입력 표시
    @State private var showsMemoEditor = false
    private var canSubmit: Bool {
        viewModel.canSave && !isLoadingPhoto && saveSubscriptionUseCase != nil && onSubscriptionSaved != nil
    }
    // MARK: - Keyboard | 빈 공간 터치 시 키보드 닫기
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "날짜 선택" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    // MARK: - Upcoming Billing Dates | 선택한 시작일과 주기에 따른 미래 예상 결제 일정
    private var upcomingBillingDates: [Date] {
        guard let startDate = viewModel.subscriptionStartDate else { return [] }
        return viewModel.cycle.upcomingBillingDates(from: startDate, count: 3)
    }
    // MARK: - Billing Date Detail | 요일 및 월말 보정 여부 표시
    private func billingDateDetail(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)
        guard let startDate = viewModel.subscriptionStartDate else { return weekday }
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: startDate)
        let billingDay = calendar.component(.day, from: date)
        return billingDay < startDay ? "\(weekday) · 월말 보정" : weekday
    }
    // MARK: - Load Photo | 기존 이미지 유지하며 비동기 선택 데이터 읽기
    @MainActor
    private func loadPhoto(_ photo: PhotosPickerItem) async {
        isLoadingPhoto = true
        defer {
            if selectedPhoto == photo {
                selectedPhoto = nil
                isLoadingPhoto = false
            }
        }
        do {
            let data = try await photo.loadTransferable(type: Data.self)
            try Task.checkCancellation()
            guard selectedPhoto == photo else { return }
            guard let data, UIImage(data: data) != nil else {
                showsPhotoLoadError = true
                return
            }
            viewModel.setImage(data)
        } catch is CancellationError {
        } catch {
            if selectedPhoto == photo { showsPhotoLoadError = true }
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                // MARK: - Name | 서비스명 필수
                entryTextField("서비스명 *", placeholder: "예: 넷플릭스", text: $viewModel.title)
                // MARK: - Cycle | 1·2·3·6·12개월 결제 주기
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("결제 주기 *")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textPrimary)
                    Menu {
                        ForEach(SubscriptionCycle.allCases, id: \.self) { cycle in
                            Button {
                                viewModel.cycle = cycle
                            } label: {
                                if viewModel.cycle == cycle {
                                    Label(cycle.title, systemImage: "checkmark")
                                } else {
                                    Text(cycle.title)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.cycle.title)
                                .foregroundStyle(AppColor.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .foregroundStyle(AppColor.primaryForeground)
                        }
                        .padding(.horizontal, AppSpacing.small)
                        .frame(height: 50)
                        .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                // MARK: - Billing Date | 구독 시작일 선택
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("구독 시작일 *")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textPrimary)
                    Button {
                        hideKeyboard()
                        pickerDate = viewModel.subscriptionStartDate ?? Date()
                        withAnimation { showsDatePicker.toggle() }
                    } label: {
                        HStack {
                            Text(formattedDate(viewModel.subscriptionStartDate))
                                .foregroundStyle(viewModel.subscriptionStartDate == nil ? AppColor.textSecondary : AppColor.textPrimary)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundStyle(AppColor.primaryForeground)
                        }
                        .padding(.horizontal, AppSpacing.small)
                        .frame(height: 50)
                        .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                    }
                    .buttonStyle(.plain)
                    if showsDatePicker {
                        VStack(spacing: AppSpacing.small) {
                            DatePicker("구독 시작일", selection: $pickerDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "ko_KR"))
                                .frame(height: 216)
                            HStack {
                                Button("취소") { withAnimation { showsDatePicker = false } }
                                    .foregroundStyle(AppColor.textSecondary)
                                Spacer()
                                Button("적용") {
                                    viewModel.subscriptionStartDate = Calendar.current.startOfDay(for: pickerDate)
                                    withAnimation { showsDatePicker = false }
                                }
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColor.primaryForeground)
                            }
                        }
                        .padding(AppSpacing.medium)
                        .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.card))
                    }
                    Text("선택한 구독 시작일을 기준으로 \(viewModel.cycle.title) 반복 표시해요.")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                // MARK: - Billing Timeline | 가까운 결제일부터 세로 타임라인으로 표시
                if !upcomingBillingDates.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        HStack {
                            Text("예상 결제 일정")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColor.textPrimary)
                            Spacer()
                            Image(systemName: "calendar.clock")
                                .foregroundStyle(AppColor.primaryForeground)
                        }
                        VStack(spacing: 0) {
                            ForEach(upcomingBillingDates.indices, id: \.self) { index in
                                let date = upcomingBillingDates[index]
                                let isNext = index == 0
                                let isLast = index == upcomingBillingDates.count - 1
                                HStack(alignment: .top, spacing: AppSpacing.small) {
                                    // MARK: - Timeline Indicator | 점과 연결선
                                    VStack(spacing: 0) {
                                        Circle()
                                            .fill(isNext ? AppColor.primary : AppColor.border)
                                            .frame(width: isNext ? 12 : 10, height: isNext ? 12 : 10)
                                            .frame(height: 14)
                                        if !isLast {
                                            Rectangle()
                                                .fill(AppColor.border)
                                                .frame(width: 2, height: 46)
                                        }
                                    }
                                    .frame(width: 16)
                                    // MARK: - Timeline Content | 예상 날짜와 요일
                                    VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                                        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xSmall) {
                                            Text(formattedDate(date))
                                                .font(.subheadline.weight(isNext ? .semibold : .medium))
                                                .foregroundStyle(AppColor.textPrimary)
                                            Spacer(minLength: 0)
                                            if isNext {
                                                Text("다음 결제")
                                                    .font(AppTypography.caption)
                                                    .foregroundStyle(AppColor.primaryForeground)
                                            }
                                        }
                                        Text(billingDateDetail(date))
                                            .font(AppTypography.caption)
                                            .foregroundStyle(AppColor.textSecondary)
                                    }
                                    .padding(.top, 0)
                                }
                            }
                        }
                        Text("실제 결제일은 서비스 정책에 따라 달라질 수 있어요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.card))
                }
                // MARK: - Amount | 천 단위 콤마와 원 단위 표시
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("결제 금액 (선택)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textPrimary)
                    HStack(spacing: 0) {
                        SubscriptionAmountTextField(amountText: $viewModel.amountText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("원")
                            .font(.body)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .padding(.horizontal, AppSpacing.small)
                    .frame(height: 50)
                    .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                    if viewModel.isInvalidAmount {
                        Text("입력 가능한 결제 금액 범위를 초과했어요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(.red)
                    } else {
                        Text("원화(₩) 기준으로 저장해요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
                // MARK: - Image | 쿠폰·이용권과 공통 이미지 컴포넌트 재사용
                RegistrationImageSection(
                    itemName: "정기 구독",
                    imageData: viewModel.imageData,
                    selectedPhoto: $selectedPhoto,
                    isLoadingPhoto: isLoadingPhoto,
                    onRemoveImage: { viewModel.removeImage() }
                )
                .alert("이미지를 불러올 수 없어요", isPresented: $showsPhotoLoadError) {
                    Button("확인", role: .cancel) {}
                } message: {
                    Text("사진을 다시 선택해주세요. 기존 입력 정보는 유지돼요.")
                }
                // MARK: - Memo | 접고 펼치는 선택 메모
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Button {
                        withAnimation { showsMemoEditor.toggle() }
                        if !showsMemoEditor { hideKeyboard() }
                    } label: {
                        HStack {
                            Text(viewModel.memo.isEmpty ? "메모 추가 (선택)" : "메모 확인 및 수정")
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
                            .scrollContentBackground(.hidden)
                            .frame(height: 120)
                            .padding(AppSpacing.xSmall)
                            .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                    }
                }
                Text("서비스명, 결제 주기, 구독 시작일은 필수 입력 항목이에요.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
                // MARK: - Save | UseCase 검증 후 홈으로 복귀
                Button {
                    hideKeyboard()
                    guard let saveSubscriptionUseCase, let onSubscriptionSaved else { return }
                    if let item = viewModel.save(using: saveSubscriptionUseCase) { onSubscriptionSaved(item) }
                } label: {
                    Text(viewModel.isSaving ? "저장 중..." : "정기 구독 저장")
                        .font(.headline)
                        .foregroundStyle(canSubmit ? AppColor.onPrimary : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(canSubmit ? AppColor.primary : AppColor.inputSurface,
                                    in: RoundedRectangle(cornerRadius: AppRadius.card))
                }
                .buttonStyle(.plain)
                .disabled(!canSubmit)
                .padding(.top, AppSpacing.medium)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.large)
            .padding(.bottom, AppSpacing.xLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Color.clear.contentShape(Rectangle()).onTapGesture { hideKeyboard() }
            }
        }
        .scrollDismissesKeyboard(.never)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("정기 구독 등록")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            hideKeyboard()
            await loadPhoto(selectedPhoto)
        }
        .alert("정기 구독 저장 실패", isPresented: $viewModel.showsSaveError) {
            Button("확인", role: .cancel) {}
        } message: { Text(viewModel.saveErrorMessage) }
    }
    private func entryTextField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(label).font(AppTypography.caption).foregroundStyle(AppColor.textPrimary)
            TextField(placeholder, text: text)
                .font(.body)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.horizontal, AppSpacing.small)
                .frame(height: 50)
                .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
        }
    }
}

// MARK: - Subscription Amount Text Field | 입력 즉시 천 단위 콤마 표시
private struct SubscriptionAmountTextField: UIViewRepresentable {
    @Binding var amountText: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .numberPad
        textField.textAlignment = .left
        textField.font = .preferredFont(forTextStyle: .body)
        textField.textColor = UIColor(AppColor.textPrimary)
        textField.tintColor = UIColor(AppColor.primaryForeground)
        textField.placeholder = "예: 17,000"
        textField.accessibilityLabel = "결제 금액"
        textField.text = Self.format(amountText)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self
        let formatted = Self.format(amountText)
        if uiView.text != formatted { uiView.text = formatted }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    private static func digitsOnly(_ text: String) -> String {
        text.filter { $0 >= "0" && $0 <= "9" }
    }

    private static func format(_ text: String) -> String {
        let digits = Array(digitsOnly(text))
        return digits.enumerated().map { index, digit in
            (index > 0 && (digits.count - index) % 3 == 0 ? "," : "") + String(digit)
        }.joined()
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SubscriptionAmountTextField

        init(_ parent: SubscriptionAmountTextField) { self.parent = parent }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let current = textField.text ?? ""
            guard let swiftRange = Range(range, in: current) else { return false }

            let candidate = current.replacingCharacters(in: swiftRange, with: string)
            let digits = SubscriptionAmountTextField.digitsOnly(candidate)
            let formatted = SubscriptionAmountTextField.format(digits)

            // 변경 위치 왼쪽에 있는 실제 숫자 개수로 커서 위치 복원
            let endOffset = min((candidate as NSString).length, range.location + (string as NSString).length)
            let prefix = (candidate as NSString).substring(to: endOffset)
            let digitsBeforeCaret = SubscriptionAmountTextField.digitsOnly(prefix).count

            var digitCount = 0
            var caretOffset = 0
            for character in formatted {
                if digitCount >= digitsBeforeCaret { break }
                caretOffset += String(character).utf16.count
                if character >= "0" && character <= "9" { digitCount += 1 }
            }

            // SwiftUI 재렌더링을 기다리지 않고 현재 UITextField에 즉시 반영
            textField.text = formatted
            if let caret = textField.position(from: textField.beginningOfDocument, offset: caretOffset) {
                textField.selectedTextRange = textField.textRange(from: caret, to: caret)
            }
            parent.amountText = digits
            return false
        }
    }
}
