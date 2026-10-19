//
//  HomeView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

struct HomeView: View {
    @State private var showsAddNotice = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: "홈",
                subtitle: "쿠폰부터 예약까지, 필요한 날짜를 한눈에",
                onAdd: { showsAddNotice = true }
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .alert("등록 화면 준비 중", isPresented: $showsAddNotice) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("추가 버튼의 화면 이동은 등록 기능 구현 시 연결할 예정이에요.")
        }
    }
}

#Preview {
    HomeView()
}
