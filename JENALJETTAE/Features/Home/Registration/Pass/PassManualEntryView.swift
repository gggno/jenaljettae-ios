//
//  PassManualEntryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/5/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - Pass Manual Entry | 이용권 직접 입력 화면
struct PassManualEntryView: View {
    // MARK: - Input State | 이용권 입력 상태
    @State private var passTitle = ""
    @State private var place = ""
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var passNumber = ""
    @State private var memo = ""

    // MARK: - Date Picker State | 시작일·종료일 선택
    private enum DateField {
        case start, end
    }

    @State private var activeDateField: DateField?
    @State private var pickerDate = Date()

    // MARK: - Image State | 이미지 선택 및 미리보기
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isLoadingPhoto = false
    @State private var showsPhotoLoadError = false
    @State private var showsImagePreview = false

    // MARK: - Memo State | 메모 입력
    @State private var showsMemoEditor = false
    @FocusState private var isMemoFocused: Bool
    
    // MARK: - Save Validation | 필수 입력값 및 날짜 검증
    private var canSave: Bool {
        !passTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        startDate != nil &&
        endDate != nil &&
        !isInvalidDateRange &&
        !isLoadingPhoto
    }

    // MARK: - Validation | 날짜 및 필수 입력값 검증
    private var isInvalidDateRange: Bool {
        guard let startDate, let endDate else { return false }
        return Calendar.current.compare(startDate, to: endDate, toGranularity: .day) == .orderedDescending
    }

    // MARK: - Date Format | 화면에 표시할 날짜
    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "날짜 선택" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    // MARK: - Hide Keyboard | 키보드 닫기
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Open Date Picker | 선택 날짜에 맞는 달력 열기
    private func openDatePicker(_ field: DateField) {
        hideKeyboard()

        if activeDateField == field {
            withAnimation { activeDateField = nil }
            return
        }

        pickerDate = (field == .start ? startDate : endDate) ?? Date()
        withAnimation { activeDateField = field }
    }

    // MARK: - Apply Date | 선택한 날짜 적용
    private func applyDate() {
        guard let activeDateField else { return }
        let date = Calendar.current.startOfDay(for: pickerDate)

        switch activeDateField {
        case .start: startDate = date
        case .end: endDate = date
        }

        withAnimation { self.activeDateField = nil }
    }

    // MARK: - Load Photo | 선택한 사진 불러오기
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

            imageData = data
        } catch is CancellationError {
            // 취소된 사진 로딩은 오류로 표시하지 않음
        } catch {
            if selectedPhoto == photo { showsPhotoLoadError = true }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {

                // MARK: - Pass Name | 이용권 이름
                PassEntryTextField(
                    label: "이름 *",
                    placeholder: "이용권 이름을 입력해주세요.",
                    text: $passTitle
                )

                // MARK: - Place | 이용처
                PassEntryTextField(
                    label: "이용처 (선택)",
                    placeholder: "이용처를 입력해주세요.",
                    text: $place
                )

                // MARK: - Pass Period | 이용 기간
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("이용 기간")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.textPrimary)

                    HStack(alignment: .top, spacing: AppSpacing.small) {
                        dateField(label: "시작일 *", date: startDate, field: .start)
                        dateField(label: "종료일 *", date: endDate, field: .end)
                    }

                    if let activeDateField {
                        datePicker(for: activeDateField)
                    }

                    if isInvalidDateRange {
                        Text("종료일은 시작일보다 빠를 수 없어요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(.red)
                    } else {
                        Text("시작일과 종료일은 필수 입력 항목이에요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                // MARK: - Pass Number | 이용권 번호
                PassEntryTextField(
                    label: "이용권 번호 (선택)",
                    placeholder: "이용권 번호를 입력해주세요.",
                    text: $passNumber
                )

                // MARK: - Pass Image | 이용권 이미지
                imageSection

                // MARK: - Memo | 메모 입력
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Button {
                        withAnimation { showsMemoEditor.toggle() }
                        if !showsMemoEditor { hideKeyboard() }
                    } label: {
                        HStack {
                            Text(memo.isEmpty ? "메모 추가 (선택)" : "메모 확인 및 수정")
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
                    }
                }

                // MARK: - Information Notice | 이용권 등록 안내
                Text("이름, 시작일, 종료일은 필수 입력 항목이에요.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)

                // MARK: - Save Button | 다음 단계에서 저장 기능 연결
                Text("이용권 저장")
                    .font(.headline)
                    .foregroundStyle(AppColor.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppRadius.card))
                    .opacity(0.5)
                    .accessibilityLabel("이용권 저장, 저장 기능 연결 전")
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.large)
            .padding(.bottom, AppSpacing.xLarge)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("이용권 등록")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            hideKeyboard()
            await loadPhoto(selectedPhoto)
        }
        .alert("이미지를 불러올 수 없어요", isPresented: $showsPhotoLoadError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("사진을 다시 선택해주세요. 기존 입력 정보는 유지돼요.")
        }
        .fullScreenCover(isPresented: $showsImagePreview) {
            if let imageData, let image = UIImage(data: imageData) {
                PassImagePreview(image: image)
            }
        }
    }

    // MARK: - Date Field | 시작일·종료일 공통 입력
    private func dateField(label: String, date: Date?, field: DateField) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textPrimary)

            Button {
                openDatePicker(field)
            } label: {
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

    // MARK: - Date Picker | 날짜 선택 및 적용
    private func datePicker(for field: DateField) -> some View {
        VStack(spacing: AppSpacing.small) {
            DatePicker(
                field == .start ? "시작일" : "종료일",
                selection: $pickerDate,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .frame(height: 216)

            HStack {
                Button("취소") {
                    withAnimation { activeDateField = nil }
                }
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

    // MARK: - Image Section | 이미지 첨부·변경·삭제
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text("이용권 이미지 (선택)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textPrimary)

            if let imageData, let image = UIImage(data: imageData) {
                Button {
                    hideKeyboard()
                    showsImagePreview = true
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.card))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
                        .overlay {
                            if isLoadingPhoto { ProgressView() }
                        }
                }
                .buttonStyle(.plain)

                HStack(spacing: AppSpacing.medium) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("사진 변경", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundStyle(AppColor.primaryForeground)
                    }

                    Button(role: .destructive) {
                        self.imageData = nil
                    } label: {
                        Label("삭제", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
                .font(.subheadline)
                .buttonStyle(.plain)
                .disabled(isLoadingPhoto)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, AppSpacing.xSmall)
            } else {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    HStack(spacing: AppSpacing.small) {
                        if isLoadingPhoto {
                            ProgressView()
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .foregroundStyle(AppColor.primaryForeground)
                        }

                        Text(isLoadingPhoto ? "이미지 불러오는 중..." : "이용권 이미지 추가")
                            .foregroundStyle(AppColor.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, AppSpacing.medium)
                    .frame(height: 56)
                    .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.input))
                }
                .buttonStyle(.plain)
                .disabled(isLoadingPhoto)
            }
        }
    }
}

// MARK: - Pass Entry Text Field | 이용권 공통 텍스트 입력
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
        }
    }
}

// MARK: - Pass Image Preview | 이미지 전체 화면 확인
private struct PassImagePreview: View {
    let image: UIImage

    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var previousScale: CGFloat = 1

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppColor.background.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = min(max(previousScale * value, 1), 5)
                        }
                        .onEnded { _ in previousScale = scale }
                )

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColor.card, in: Circle())
            }
            .padding(AppSpacing.medium)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PassManualEntryView()
    }
}
