//
//  LibraryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("보관함")
                .font(AppTypography.screenTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text("보관함 화면 개발 예정")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.background.ignoresSafeArea())
    }
}
  
