//
//  CouponRegistrationMethodView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/21/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - Coupon Registration Method | 쿠폰 등록 방법 선택 및 이미지 가져오기
struct CouponRegistrationMethodView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showsImageRecognition = false
    @State private var isLoadingPhoto = false
    @State private var showsPhotoLoadError = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {

            // MARK: - Description | 쿠폰 등록 방법 안내
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text("쿠폰·기프티콘")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.primaryForeground)

                Text("어떻게 등록할까요?")
                    .font(.title2.bold())
                    .foregroundStyle(AppColor.textPrimary)

                Text("이미지 속 글자를 AI로 읽어 입력을 도와줘요.")
                    .font(.body)
                    .foregroundStyle(AppColor.textSecondary)
            }

            // MARK: - Registration Buttons | AI 이미지 선택 또는 직접 입력
            VStack(spacing: AppSpacing.small) {

                // MARK: - AI Coupon Reading | 사진첩에서 쿠폰 이미지 선택
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    HStack(spacing: AppSpacing.small) {
                        if isLoadingPhoto {
                            ProgressView()
                                .tint(AppColor.onPrimary)
                        }

                        Text(isLoadingPhoto ? "이미지 불러오는 중..." : "AI로 쿠폰 읽기")
                            .font(.headline)
                    }
                    .foregroundStyle(AppColor.onPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        AppColor.primary,
                        in: RoundedRectangle(cornerRadius: AppRadius.card)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isLoadingPhoto)

                // MARK: - Manual Entry | 기존 쿠폰 직접 입력 화면으로 이동
                NavigationLink {
                    CouponManualEntryView()
                } label: {
                    Text("직접 입력하기")
                        .font(.headline)
                        .foregroundStyle(AppColor.primaryForeground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            AppColor.card,
                            in: RoundedRectangle(cornerRadius: AppRadius.card)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: AppRadius.card)
                                .stroke(AppColor.border, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }

            // MARK: - Sample Coupon | AI 등록 안내용 샘플 카드
            VStack(spacing: AppSpacing.xSmall) {
                Image(AppIcon.coupon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(AppColor.primaryForeground)

                Text("아메리카노 교환권")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)

                Text("COUPON SAMPLE")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                AppColor.primaryTint,
                in: RoundedRectangle(cornerRadius: AppRadius.card)
            )

            // MARK: - Guide | 사진 선택 후 인식 과정 안내
            Text("사진 한 장을 선택한 뒤 인식한 내용을 확인하고 수정할 수 있어요.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.large)
        .padding(.bottom, AppSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("쿠폰 등록 방법")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Photo Selection | 선택한 이미지 데이터 불러오기
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let newPhoto else { return }
            Task { await loadPhoto(newPhoto) }
        }

        // MARK: - Image Preview Navigation | 이미지 불러오기 성공 시 다음 화면 이동
        .navigationDestination(isPresented: $showsImageRecognition) {
            if let imageData {
                CouponImageRecognitionView(
                    imageData: imageData,
                    analyzeCouponImageUseCase: AnalyzeCouponImageUseCase(
                        repository: GeminiCouponAnalysisRepository()
                    )
                )
            }
        }

        // MARK: - Photo Load Error | 이미지 불러오기 실패 안내
        .alert("이미지를 불러올 수 없어요", isPresented: $showsPhotoLoadError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("사진을 다시 선택해주세요.")
        }
    }

    // MARK: - Load Photo | 선택한 이미지를 Data로 변환하고 이미지 인식 화면으로 이동
    @MainActor
    private func loadPhoto(_ photo: PhotosPickerItem) async {
        isLoadingPhoto = true

        defer {
            isLoadingPhoto = false
            selectedPhoto = nil
        }

        do {
            guard let data = try await photo.loadTransferable(type: Data.self),
                  UIImage(data: data) != nil else {
                showsPhotoLoadError = true
                return
            }

            imageData = data
            showsImageRecognition = true
        } catch {
            showsPhotoLoadError = true
        }
    }
}
