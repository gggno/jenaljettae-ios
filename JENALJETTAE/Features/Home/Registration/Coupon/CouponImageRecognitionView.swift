//
//  CouponImageRecognitionView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/30/26.
//

import SwiftUI
import UIKit

// MARK: - Coupon Image Recognition View | Gemini 이미지 분석 후 쿠폰 등록 화면으로 이동
struct CouponImageRecognitionView: View {
    let imageData: Data
    let analyzeCouponImageUseCase: AnalyzeCouponImageUseCase

    @State private var extractedDraft = CouponDraft()
    @State private var isRecognizing = false
    @State private var showsRecognitionError = false
    @State private var recognitionErrorMessage = ""
    @State private var navigateToManualEntry = false
    @State private var analysisTask: Task<Void, Never>?

    // MARK: - Initialization | 이미지와 분석 UseCase 주입
    init(imageData: Data, analyzeCouponImageUseCase: AnalyzeCouponImageUseCase) {
        self.imageData = imageData
        self.analyzeCouponImageUseCase = analyzeCouponImageUseCase
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {

            // MARK: - Description | 이미지 확인 및 AI 분석 안내
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text("선택한 쿠폰을 확인해주세요.")
                    .font(.title3.bold())
                    .foregroundStyle(AppColor.textPrimary)

                Text("AI가 이미지에서 쿠폰 정보를 자동으로 추출해요.")
                    .font(.body)
                    .foregroundStyle(AppColor.textSecondary)
            }

            // MARK: - Image Preview | 선택한 쿠폰 이미지 표시
            GeometryReader { geometry in
                if let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .accessibilityLabel("선택한 쿠폰 이미지")
                }
            }

            // MARK: - Recognition Button | 분석 UseCase 실행
            Button {
                analysisTask = Task { await analyzeImage() }
            } label: {
                HStack(spacing: AppSpacing.small) {
                    if isRecognizing { ProgressView().tint(AppColor.onPrimary) }

                    Text(isRecognizing ? "쿠폰 분석 중..." : "쿠폰 정보 인식하기")
                        .font(.headline)
                }
                .foregroundStyle(AppColor.onPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppColor.primary, in: RoundedRectangle(cornerRadius: AppRadius.card))
            }
            .buttonStyle(.plain)
            .disabled(isRecognizing)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.large)
        .padding(.bottom, AppSpacing.small)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("쿠폰 이미지 확인")
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Cancel Analysis | 화면을 벗어나면 분석 요청 취소
        .onDisappear {
            analysisTask?.cancel()
        }

        // MARK: - Registration Navigation | 분석 완료 시 결과와 원본 이미지를 바로 전달
        .navigationDestination(isPresented: $navigateToManualEntry) {
            CouponManualEntryView(
                initialDraft: extractedDraft,
                initialImageData: imageData
            )
        }

        // MARK: - Recognition Error | 이미지 분석 실패 안내
        .alert("쿠폰 분석 실패", isPresented: $showsRecognitionError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(recognitionErrorMessage)
        }
    }

    // MARK: - Analyze Image | 분석 성공 시 바텀시트 없이 쿠폰 등록 화면으로 이동
    @MainActor
    private func analyzeImage() async {
        guard !isRecognizing else { return }

        isRecognizing = true
        defer { isRecognizing = false }

        do {
            try Task.checkCancellation()

            let draft = try await analyzeCouponImageUseCase.execute(imageData: imageData)

            try Task.checkCancellation()
            extractedDraft = draft
            navigateToManualEntry = true
        } catch is CancellationError {
            // 화면 이탈로 취소한 분석 요청은 오류를 표시하지 않음
        } catch {
            recognitionErrorMessage = error.localizedDescription
            showsRecognitionError = true
        }
    }
}
