//
//  CouponManualEntryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - Coupon Manual Entry | 쿠폰 직접 입력 및 저장 화면
struct CouponManualEntryView: View {
    let initialDraft: CouponDraft?
    let initialImageData: Data?

    @Environment(\.saveCouponUseCase) private var saveCouponUseCase
    @Environment(\.onCouponSaved) private var onCouponSaved

    @StateObject private var viewModel = CouponRegistrationViewModel()

    @State private var pickerDate = Date()
    @State private var showsDatePicker = false
    @State private var showsMemoEditor = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var hasAppliedInitialData = false

    // MARK: - Photo Selection State | 사진 선택과 비동기 로딩 상태 관리
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var showsPhotoLoadError = false

    // MARK: - AI Image State | AI 분석 원본 이미지 변경 여부 관리
    @State private var hasChangedAnalyzedImage = false

    @FocusState private var isMemoFocused: Bool

    // MARK: - Initialization | AI 분석 결과와 원본 이미지 전달받기
    init(initialDraft: CouponDraft? = nil, initialImageData: Data? = nil) {
        self.initialDraft = initialDraft
        self.initialImageData = initialImageData
    }

    // MARK: - Save Validation | 사진 로딩 중 저장 방지 및 기존 필수값 확인
    private var canSubmit: Bool {
        viewModel.canSave && !isLoadingPhoto && saveCouponUseCase != nil && onCouponSaved != nil
    }

    // MARK: - Expiry Date Text | 선택한 만료일 표시
    private var expiryDateText: String {
        guard let expiryDate = viewModel.expiryDate else { return "날짜 선택" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: expiryDate)
    }

    // MARK: - Expired Coupon | 현재 선택한 만료일 기준으로 만료 여부 확인
    private var isExpiredCoupon: Bool {
        guard let expiryDate = viewModel.expiryDate else { return false }
        let calendar = Calendar.current
        return calendar.startOfDay(for: expiryDate) < calendar.startOfDay(for: Date())
    }

    // MARK: - Hide Keyboard | 입력 중인 키보드 닫기
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Load Photo | 사진 로딩 성공 시에만 기존 이미지 교체
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
            if initialDraft != nil { hasChangedAnalyzedImage = true }

        } catch is CancellationError {
            // 화면 이탈 등으로 취소된 로딩은 오류를 표시하지 않음
        } catch {
            if selectedPhoto == photo { showsPhotoLoadError = true }
        }
    }

    var body: some View {
        // MARK: - Input Content | 전체 쿠폰 등록 화면 스크롤
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.large) {

                    // MARK: - Coupon Image | 쿠폰 이미지 선택·변경·삭제
                    CouponImageSection(
                        imageData: viewModel.imageData,
                        selectedPhoto: $selectedPhoto,
                        isLoadingPhoto: isLoadingPhoto,
                        onRemoveImage: {
                            viewModel.removeImage()
                            if initialDraft != nil { hasChangedAnalyzedImage = true }
                        }
                    )
                    .alert("이미지를 불러올 수 없어요", isPresented: $showsPhotoLoadError) {
                        Button("확인", role: .cancel) {}
                    } message: {
                        Text("사진을 다시 선택해주세요. 기존 입력 정보는 유지돼요.")
                    }

                    // MARK: - Review Notes | AI 분석 이미지 상태에 따라 확인 안내 변경
                    if let initialDraft,
                       viewModel.imageData != nil,
                       hasChangedAnalyzedImage || !initialDraft.reviewNotes.isEmpty {

                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            HStack(spacing: AppSpacing.xSmall) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.orange)

                                Text(hasChangedAnalyzedImage ? "이미지를 확인해주세요." : "확인 필요한 항목")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppColor.textPrimary)
                            }

                            if !hasChangedAnalyzedImage {
                                Text("AI가 정확하게 인식했는지 확인해주세요.")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                            }

                            if hasChangedAnalyzedImage {
                                Text("• 이미지와 입력된 쿠폰 정보가 일치하는지 확인해주세요.")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                            } else {
                                ForEach(initialDraft.reviewNotes.indices, id: \.self) { index in
                                    Text("• \(initialDraft.reviewNotes[index])")
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                            }
                        }
                        .padding(AppSpacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.card))
                        .padding(.bottom, AppSpacing.medium)
                    }

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
                            withAnimation { showsDatePicker.toggle() }
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

                        // MARK: - Inline Date Picker | 만료일 선택 및 적용
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
                                        withAnimation { showsDatePicker = false }
                                    }
                                    .foregroundStyle(AppColor.textSecondary)

                                    if viewModel.expiryDate != nil {
                                        Button("날짜 지우기") {
                                            viewModel.expiryDate = nil
                                            withAnimation { showsDatePicker = false }
                                        }
                                        .foregroundStyle(AppColor.textSecondary)
                                    }

                                    Spacer()

                                    Button("적용") {
                                        viewModel.expiryDate = Calendar.current.startOfDay(for: pickerDate)
                                        withAnimation { showsDatePicker = false }
                                    }
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppColor.primaryForeground)
                                }
                            }
                            .padding(AppSpacing.medium)
                            .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.card))
                        }

                        // MARK: - Expiry Warning | 만료된 쿠폰 안내
                        if isExpiredCoupon {
                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                HStack(spacing: AppSpacing.xSmall) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundStyle(.orange)

                                    Text("이미 만료된 쿠폰이에요.")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColor.textPrimary)
                                }

                                Text("유효기간을 확인해주세요. 만료된 쿠폰도 기록용으로 등록할 수 있어요.")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                            .padding(AppSpacing.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.card))
                            .padding(.top, AppSpacing.xSmall)
                            .padding(.bottom, AppSpacing.medium)
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
                                .focused($isMemoFocused)
                                .scrollContentBackground(.hidden)
                                .frame(height: 120)
                                .padding(AppSpacing.xSmall)
                                .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                                .id("memoEditor")
                                .onAppear { isMemoFocused = true }
                        }
                    }

                    // MARK: - Required Fields Notice | 필수 입력 항목 안내
                    Text("상품명과 만료일은 필수 입력 항목이에요.")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)

                    // MARK: - Save Button | 스크롤 영역 최하단에 쿠폰 저장 버튼 배치
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
                    .padding(.top, AppSpacing.medium)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.large)
                .padding(.bottom, AppSpacing.xLarge + keyboardHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { hideKeyboard() }
                }
            }
            .scrollDismissesKeyboard(.never)
            .background {
                AppColor.background
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }
            }

            // MARK: - Memo Auto Scroll | 메모 입력 시 스크롤 위치 조정
            .onChange(of: isMemoFocused) { _, focused in
                guard focused else { return }
                withAnimation { proxy.scrollTo("memoEditor", anchor: .top) }
            }
            .onChange(of: keyboardHeight) { _, height in
                guard height > 0 && isMemoFocused else { return }
                withAnimation { proxy.scrollTo("memoEditor", anchor: .top) }
            }
            .onChange(of: viewModel.memo) { _, newMemo in
                guard isMemoFocused && newMemo.hasSuffix("\n") else { return }
                withAnimation { proxy.scrollTo("memoEditor", anchor: .top) }
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)

        // MARK: - Apply Initial Data | AI 분석 결과와 이미지를 최초 진입 시 한 번만 적용
        .onAppear {
            guard !hasAppliedInitialData else { return }
            hasAppliedInitialData = true

            if let initialDraft {
                viewModel.apply(draft: initialDraft)
                if let expiryDate = initialDraft.expiryDate { pickerDate = expiryDate }
            }

            if let initialImageData {
                viewModel.setImage(initialImageData)
            }
        }
        .navigationTitle("쿠폰 등록")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Photo Loading | 사진 선택 변경 시 자동 로딩하고 화면 이탈 시 취소
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            hideKeyboard()
            await loadPhoto(selectedPhoto)
        }

        // MARK: - Keyboard Height | 메모 입력 시 스크롤 여백 계산
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = max(0, UIScreen.main.bounds.maxY - frame.minY)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }

        // MARK: - Save Error | 저장 실패 안내
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

// MARK: - Preview | 직접 입력 화면 미리보기
#Preview {
    NavigationStack {
        CouponManualEntryView()
    }
    .environment(\.saveCouponUseCase, SaveCouponUseCase(repository: SampleManagedItemRepository()))
    .environment(\.onCouponSaved, { _ in })
}
