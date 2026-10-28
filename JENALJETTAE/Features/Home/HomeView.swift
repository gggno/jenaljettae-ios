//
//  HomeView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

// MARK: - Home View | 홈 달력 표시 및 일정 관리
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    private let repository: any ManagedItemRepository

    @State private var showsRegistrationTypeSelection = false
    @State private var showsSampleDetail = false

    // MARK: - Dependency Injection | Repository로 홈 ViewModel 생성
    init(repository: any ManagedItemRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Type Filter | 선택 유형에 맞게 달력 및 목록 갱신
            TypeFilter(
                selectedType: viewModel.selectedType,
                onSelect: { viewModel.selectedType = $0 }
            )

            ScrollView {
                VStack(spacing: AppSpacing.sectionSpacing) {
                    // MARK: - Month Calendar | 월 이동 및 날짜 선택 연결
                    MonthCalendar(
                        visibleMonth: viewModel.visibleMonth,
                        selectedDate: viewModel.selectedDate,
                        today: Date(),
                        events: viewModel.calendarEvents,
                        onDateSelect: { viewModel.selectDate($0) },
                        onMonthChange: { viewModel.changeMonth(to: $0) },
                        onToday: { viewModel.moveToToday() },
                        onDatePicked: { viewModel.pickDate($0) }
                    )
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: - Selected Date Events | 선택 날짜의 일정 목록 표시
                    SelectedDateEventsView(
                        selectedDate: viewModel.selectedDate,
                        events: viewModel.filteredEvents,
                        onEventTap: { showsSampleDetail = true }
                    )
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                }
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.xLarge)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .modifier(HomeScrollEdgeStyle())
        .navigationTitle("홈")
        .modifier(HomeNavigationTitleStyle())

        // MARK: - Add Toolbar | iOS 버전에 맞춰 추가 버튼 배치
        .toolbar {
            if #available(iOS 27.1, *) {
                ToolbarItem(placement: .topBarPinnedTrailing) {
                    addToolbarButton
                }
                .axisBehavior(.verticalPreferred)
                .visibilityPriority(.high)
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    addToolbarButton
                }
            }
        }

        // MARK: - Registration | 쿠폰 저장 기능과 완료 처리를 Environment에 등록
        .fullScreenCover(isPresented: $showsRegistrationTypeSelection) {
            NavigationStack {
                RegistrationTypeSelectionView()
            }
            .environment(\.saveCouponUseCase, SaveCouponUseCase(repository: repository))
            .environment(\.onCouponSaved, { savedItem in
                viewModel.reload()

                if let expiryDate = savedItem.endDate {
                    viewModel.pickDate(expiryDate)
                }

                showsRegistrationTypeSelection = false
            })
        }

        // MARK: - Detail Alert | 상세 화면 구현 전 임시 안내
        .alert("일정 상세 화면 준비 중", isPresented: $showsSampleDetail) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("상세 화면은 아직 준비 중이에요.")
        }
    }

    // MARK: - Add Toolbar Button | 등록 유형 선택 화면 열기
    private var addToolbarButton: some View {
        Button {
            showsRegistrationTypeSelection = true
        } label: {
            Label("항목 추가", image: AppIcon.add)
        }
        .tint(AppColor.textPrimary)
    }
}

// MARK: - Navigation Title Style | iOS 버전에 맞는 제목 표시 방식
private struct HomeNavigationTitleStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.toolbarTitleDisplayMode(.inlineLarge)
        } else {
            content.navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Scroll Edge Style | iOS 26 이상 상단 스크롤 효과 제거
private struct HomeScrollEdgeStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.scrollEdgeEffectHidden(true, for: .top)
        } else {
            content
        }
    }
}

// MARK: - Preview | 홈 화면 미리보기
#Preview {
    NavigationStack {
        HomeView(repository: SampleManagedItemRepository())
    }
}
