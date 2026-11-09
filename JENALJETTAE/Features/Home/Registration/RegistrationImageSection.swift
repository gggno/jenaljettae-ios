//
//  RegistrationImageSection.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/5/26.
//

import SwiftUI
import PhotosUI
import UIKit

// MARK: - Registration Image Section | 등록 이미지 선택·변경·삭제 및 전체 화면 보기
struct RegistrationImageSection: View {
    let itemName: String
    let imageData: Data?
    @Binding var selectedPhoto: PhotosPickerItem?
    let isLoadingPhoto: Bool
    let onRemoveImage: () -> Void

    @State private var showsImagePreview = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text("\(itemName) 이미지 (선택)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textPrimary)

            if let imageData, let image = UIImage(data: imageData) {
                // MARK: - Image Card | 쿠폰과 동일한 원본 비율·모서리 라운드
                Button {
                    showsImagePreview = true
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            if isLoadingPhoto { ProgressView() }
                        }
                }
                .buttonStyle(.plain)
                .disabled(isLoadingPhoto)
                .accessibilityLabel("\(itemName) 이미지 전체 화면 보기")

                // MARK: - Image Actions | 사진 변경·삭제 버튼 오른쪽 정렬
                HStack(spacing: AppSpacing.medium) {
                    Spacer(minLength: 0)

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("사진 변경", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundStyle(AppColor.primaryForeground)
                    }
                    .disabled(isLoadingPhoto)

                    Button(role: .destructive) { onRemoveImage() } label: {
                        Label("삭제", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                    .disabled(isLoadingPhoto)
                }
                .font(.subheadline)
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.xSmall)
            } else {
                // MARK: - Empty Image Card | 쿠폰과 동일한 200pt 이미지 첨부 카드
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    VStack(spacing: AppSpacing.xSmall) {
                        if isLoadingPhoto {
                            ProgressView()
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .font(.title2)
                                .foregroundStyle(AppColor.textSecondary)
                        }

                        Text(isLoadingPhoto ? "이미지 불러오는 중..." : "\(itemName) 이미지 추가")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColor.textPrimary)

                        Text("이미지가 없어도 등록할 수 있어요.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.card))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .strokeBorder(AppColor.border, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isLoadingPhoto)
            }
        }
        .fullScreenCover(isPresented: $showsImagePreview) {
            if let imageData, let image = UIImage(data: imageData) {
                RegistrationImagePreviewView(image: image)
            }
        }
    }
}
