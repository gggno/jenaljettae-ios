//
//  PassManualEntryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/5/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - Pass Manual Entry | 이용권 직접 입력 및 저장
struct PassManualEntryView: View {
    let editingItem: ManagedItem?
    init(editingItem: ManagedItem? = nil) { self.editingItem = editingItem }
    @State private var hasAppliedEditingItem = false
    // MARK: - Dependencies | 이용권 저장 기능 및 저장 후 홈 갱신
    @Environment(\.savePassUseCase) private var savePassUseCase
    @Environment(\.onPassSaved) private var onPassSaved
    @StateObject private var viewModel = PassRegistrationViewModel()

    // MARK: - Date Picker | 시작일·종료일
    private enum DateField: Equatable { case start, end }
    @State private var activeDateField: DateField?
    @State private var pickerDate = Date()

    // MARK: - Image | 사진 선택 및 로딩 상태
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var showsPhotoLoadError = false

    // MARK: - Memo | 메모 펼치기
    @State private var showsMemoEditor = false
    @FocusState private var isMemoFocused: Bool

    // MARK: - Save Validation | 필수값과 주입된 저장 의존성 확인
    private var canSubmit: Bool {
        viewModel.canSave && !isLoadingPhoto && savePassUseCase != nil && onPassSaved != nil
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "날짜 선택" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Date Selection | 선택한 날짜를 ViewModel에 반영
    private func openDatePicker(_ field: DateField) {
        hideKeyboard()
        if activeDateField == field {
            withAnimation { activeDateField = nil }
            return
        }
        pickerDate = (field == .start ? viewModel.startDate : viewModel.endDate) ?? Date()
        withAnimation { activeDateField = field }
    }

    private func applyDate() {
        guard let activeDateField else { return }
        let date = Calendar.current.startOfDay(for: pickerDate)
        switch activeDateField {
        case .start: viewModel.startDate = date
        case .end: viewModel.endDate = date
        }
        withAnimation { self.activeDateField = nil }
    }

    // MARK: - Photo | 정상 로딩된 이미지만 ViewModel에 저장
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
            // 사진 선택을 취소하거나 화면을 벗어난 경우 무시
        } catch {
            if selectedPhoto == photo { showsPhotoLoadError = true }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                // MARK: - Name | 필수
                PassEntryTextField(label: "이름 *", placeholder: "이용권 이름을 입력해주세요.", text: $viewModel.passTitle)

                // MARK: - Place | 선택
                PassEntryTextField(label: "이용처 (선택)", placeholder: "이용처를 입력해주세요.", text: $viewModel.place)

                // MARK: - Date Range | 필수
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("이용 기간")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.textPrimary)

                    HStack(alignment: .top, spacing: AppSpacing.small) {
                        dateField(label: "시작일 *", date: viewModel.startDate, field: .start)
                        dateField(label: "종료일 *", date: viewModel.endDate, field: .end)
                    }

                    if let activeDateField { datePicker(for: activeDateField) }

                    if viewModel.isInvalidDateRange {
                        Text("종료일은 시작일보다 빠를 수 없어요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(.red)
                    } else {
                        Text("시작일과 종료일은 필수 입력 항목이에요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                // MARK: - Number | 선택
                PassEntryTextField(label: "이용권 번호 (선택)", placeholder: "이용권 번호를 입력해주세요.", text: $viewModel.passNumber)

                // MARK: - Image | 쿠폰과 동일한 공통 이미지 영역
                RegistrationImageSection(
                    itemName: "이용권",
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

                // MARK: - Memo | 선택
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
                    }
                }

                Text("이름, 시작일, 종료일은 필수 입력 항목이에요.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)

                // MARK: - Save | ViewModel → UseCase → Repository
                Button {
                    hideKeyboard()
                    guard let savePassUseCase, let onPassSaved else { return }
                    if let savedItem = viewModel.savePass(using: savePassUseCase, editingItem: editingItem) { onPassSaved(savedItem) }
                } label: {
                    Text(viewModel.isSaving ? "저장 중..." : (editingItem == nil ? "이용권 저장" : "수정 완료"))
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
        .navigationTitle(editingItem == nil ? "이용권 등록" : "이용권 수정")
        .onAppear {
            guard !hasAppliedEditingItem, let editingItem else { return }
            hasAppliedEditingItem = true
            viewModel.apply(editingItem: editingItem)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            hideKeyboard()
            await loadPhoto(selectedPhoto)
        }
        .alert("이용권 저장 실패", isPresented: $viewModel.showsSaveError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage)
        }
    }

    private func dateField(label: String, date: Date?, field: DateField) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textPrimary)

            Button { openDatePicker(field) } label: {
                HStack(spacing: 4) {
                    Text(formattedDate(date))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(date == nil ? AppColor.textSecondary : AppColor.textPrimary)
                    Spacer(minLength: 0)
                    Image(systemName: "calendar")
                        .foregroundStyle(AppColor.primaryForeground)
                }
                .font(.subheadline)
                .padding(.horizontal, AppSpacing.xSmall)
                .frame(height: 50)
                .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private func datePicker(for field: DateField) -> some View {
        VStack(spacing: AppSpacing.small) {
            DatePicker(field == .start ? "시작일" : "종료일", selection: $pickerDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .frame(height: 216)

            HStack {
                Button("취소") { withAnimation { activeDateField = nil } }
                    .foregroundStyle(AppColor.textSecondary)
                Spacer()
                Button("적용") { applyDate() }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.primaryForeground)
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.card))
    }
}

// MARK: - Pass Entry Text Field | 이용권 공통 텍스트 입력 UI
private struct PassEntryTextField: View {
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

// MARK: - Preview | 의존성 주입 테스트
#Preview {
    NavigationStack { PassManualEntryView() }
        .environment(\.savePassUseCase, SavePassUseCase(repository: SampleManagedItemRepository()))
        .environment(\.onPassSaved, { _ in })
}
