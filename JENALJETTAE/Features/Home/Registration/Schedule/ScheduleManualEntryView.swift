//
//  ScheduleManualEntryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/6/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - Schedule Manual Entry | 하루 일정·기간 일정 등록
struct ScheduleManualEntryView: View {

    // MARK: - Dependencies | 일정 저장 의존성
    @Environment(\.saveScheduleUseCase) private var saveScheduleUseCase
    @Environment(\.onScheduleSaved) private var onScheduleSaved

    @StateObject private var viewModel = ScheduleRegistrationViewModel()

    // MARK: - Date State | 시작일·종료일 선택
    private enum DateField: Equatable {
        case start
        case end
    }

    @State private var activeDateField: DateField?
    @State private var pickerDate = Date()

    // MARK: - Time State | 시작 시간 선택
    @State private var showsTimePicker = false
    @State private var pickerTime = Date()

    // MARK: - Image State | 공통 이미지 선택
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var showsPhotoLoadError = false

    // MARK: - Memo State | 메모 입력
    @State private var showsMemoEditor = false

    // MARK: - Can Submit | 저장 가능 여부
    private var canSubmit: Bool {
        viewModel.canSave &&
        !isLoadingPhoto &&
        saveScheduleUseCase != nil &&
        onScheduleSaved != nil
    }

    // MARK: - Keyboard | 키보드 닫기
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    // MARK: - Date Format | 날짜 표시
    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "날짜 선택" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    // MARK: - Time Format | 시간 표시
    private func formattedTime(_ minutes: Int?) -> String {
        guard let minutes else { return "시간 추가 (선택)" }

        let hour = minutes / 60
        let minute = minutes % 60
        return String(format: "%02d:%02d", hour, minute)
    }

    // MARK: - Open Date Picker | 시작일·종료일 선택기 열기
    private func openDatePicker(_ field: DateField) {
        hideKeyboard()
        showsTimePicker = false

        if activeDateField == field {
            withAnimation { activeDateField = nil }
            return
        }

        pickerDate = (field == .start ? viewModel.startDate : viewModel.endDate) ?? viewModel.startDate ?? Date()
        withAnimation { activeDateField = field }
    }

    // MARK: - Apply Date | 선택 날짜 반영
    private func applyDate() {
        guard let field = activeDateField else { return }

        let date = Calendar.current.startOfDay(for: pickerDate)

        if field == .start {
            viewModel.startDate = date
        } else {
            viewModel.endDate = date
        }

        withAnimation { activeDateField = nil }
    }

    // MARK: - Open Time Picker | 시작 시간 선택기 열기
    private func openTimePicker() {
        hideKeyboard()
        activeDateField = nil

        if showsTimePicker {
            withAnimation { showsTimePicker = false }
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        pickerTime = Calendar.current.date(
            byAdding: .minute,
            value: viewModel.timeMinutes ?? 9 * 60,
            to: today
        ) ?? Date()

        withAnimation { showsTimePicker = true }
    }

    // MARK: - Apply Time | 시작 시간을 분 단위로 저장
    private func applyTime() {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: pickerTime)
        viewModel.timeMinutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        withAnimation { showsTimePicker = false }
    }

    // MARK: - Load Photo | 이미지 선택 및 검증
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
            // 화면 이탈로 인한 취소는 오류로 처리하지 않음
        } catch {
            if selectedPhoto == photo { showsPhotoLoadError = true }
        }
    }

    // MARK: - Body | 일정 등록 UI
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {

                // MARK: - Schedule Name | 일정명 필수 입력
                entryTextField(
                    "일정명 *",
                    placeholder: "예: 치과 예약, 호텔 숙박",
                    text: $viewModel.title
                )

                // MARK: - Place | 장소 선택 입력
                entryTextField(
                    "장소 (선택)",
                    placeholder: "장소를 입력해주세요.",
                    text: $viewModel.place
                )

                // MARK: - Dates | 시작일·종료일 모두 필수
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("일정 날짜")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.textPrimary)

                    HStack(spacing: AppSpacing.small) {
                        dateField(
                            "시작일 *",
                            date: viewModel.startDate,
                            field: .start
                        )

                        dateField(
                            "종료일 *",
                            date: viewModel.endDate,
                            field: .end
                        )
                    }

                    if let activeDateField {
                        datePicker(for: activeDateField)
                    }

                    if viewModel.isInvalidDateRange {
                        Text("종료일은 시작일보다 빠를 수 없어요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(.red)
                    } else {
                        Text("시작일과 종료일은 필수예요. 하루 일정은 같은 날짜를 선택해주세요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }

                // MARK: - Optional Time | 시작 시간 선택
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Text("시작 시간 (선택)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textPrimary)

                    Button(action: openTimePicker) {
                        HStack {
                            Text(formattedTime(viewModel.timeMinutes))
                                .foregroundStyle(
                                    viewModel.timeMinutes == nil
                                    ? AppColor.textSecondary
                                    : AppColor.textPrimary
                                )

                            Spacer()

                            Image(systemName: "clock")
                                .foregroundStyle(AppColor.primaryForeground)
                        }
                        .padding(.horizontal, AppSpacing.small)
                        .frame(height: 50)
                        .background(
                            AppColor.inputSurface,
                            in: RoundedRectangle(cornerRadius: AppRadius.input)
                        )
                    }
                    .buttonStyle(.plain)

                    if showsTimePicker {
                        VStack(spacing: AppSpacing.small) {
                            DatePicker(
                                "시작 시간",
                                selection: $pickerTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                            .frame(height: 216)

                            HStack {
                                Button("취소") {
                                    withAnimation { showsTimePicker = false }
                                }
                                .foregroundStyle(AppColor.textSecondary)

                                Spacer()

                                Button("적용", action: applyTime)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppColor.primaryForeground)
                            }
                        }
                        .padding(AppSpacing.medium)
                        .background(
                            AppColor.card,
                            in: RoundedRectangle(cornerRadius: AppRadius.card)
                        )
                    }

                    if viewModel.timeMinutes != nil {
                        Button("시간 제거") { viewModel.removeTime() }
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.primaryForeground)
                    }
                }

                // MARK: - Image | 공통 이미지 등록 UI
                RegistrationImageSection(
                    itemName: "일정",
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

                // MARK: - Memo | 메모 입력
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    Button {
                        withAnimation { showsMemoEditor.toggle() }
                        if !showsMemoEditor { hideKeyboard() }
                    } label: {
                        HStack {
                            Text(
                                viewModel.memo.isEmpty
                                ? "메모 추가 (선택)"
                                : "메모 확인 및 수정"
                            )
                            .foregroundStyle(AppColor.textPrimary)

                            Spacer()

                            Image(systemName: showsMemoEditor ? "chevron.up" : "chevron.down")
                                .foregroundStyle(AppColor.textSecondary)
                        }
                        .font(.subheadline)
                        .padding(AppSpacing.medium)
                        .background(
                            AppColor.inputSurface,
                            in: RoundedRectangle(cornerRadius: AppRadius.input)
                        )
                    }
                    .buttonStyle(.plain)

                    if showsMemoEditor {
                        TextEditor(text: $viewModel.memo)
                            .font(.body)
                            .foregroundStyle(AppColor.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(height: 120)
                            .padding(AppSpacing.xSmall)
                            .background(
                                AppColor.inputSurface,
                                in: RoundedRectangle(cornerRadius: AppRadius.input)
                            )
                    }
                }

                // MARK: - Required Notice | 필수 입력 안내
                Text("일정명, 시작일, 종료일은 필수 입력 항목이에요.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)

                // MARK: - Save Button | 일정 저장
                Button {
                    hideKeyboard()

                    guard let saveScheduleUseCase,
                          let onScheduleSaved else { return }

                    if let item = viewModel.save(using: saveScheduleUseCase) {
                        onScheduleSaved(item)
                    }
                } label: {
                    Text(viewModel.isSaving ? "저장 중..." : "일정 저장")
                        .font(.headline)
                        .foregroundStyle(
                            canSubmit ? AppColor.onPrimary : AppColor.textSecondary
                        )
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
            .padding(.bottom, AppSpacing.xLarge)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { hideKeyboard() }
            }
        }
        .scrollDismissesKeyboard(.never)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("일정 등록")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            hideKeyboard()
            await loadPhoto(selectedPhoto)
        }
        .alert("일정 저장 실패", isPresented: $viewModel.showsSaveError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage)
        }
    }

    // MARK: - Date Field | 시작일·종료일 입력 UI
    private func dateField(
        _ title: String,
        date: Date?,
        field: DateField
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textPrimary)

            Button { openDatePicker(field) } label: {
                HStack(spacing: 4) {
                    Text(formattedDate(date))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(
                            date == nil
                            ? AppColor.textSecondary
                            : AppColor.textPrimary
                        )

                    Spacer(minLength: 0)

                    Image(systemName: "calendar")
                        .foregroundStyle(AppColor.primaryForeground)
                }
                .font(.subheadline)
                .padding(.horizontal, AppSpacing.xSmall)
                .frame(height: 50)
                .background(
                    AppColor.inputSurface,
                    in: RoundedRectangle(cornerRadius: AppRadius.input)
                )
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

                Button("적용", action: applyDate)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColor.primaryForeground)
            }
        }
        .padding(AppSpacing.medium)
        .background(
            AppColor.card,
            in: RoundedRectangle(cornerRadius: AppRadius.card)
        )
    }

    // MARK: - Entry Text Field | 공통 텍스트 입력 UI
    private func entryTextField(
        _ label: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textPrimary)

            TextField(placeholder, text: text)
                .font(.body)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.horizontal, AppSpacing.small)
                .frame(height: 50)
                .background(
                    AppColor.inputSurface,
                    in: RoundedRectangle(cornerRadius: AppRadius.input)
                )
        }
    }
}
