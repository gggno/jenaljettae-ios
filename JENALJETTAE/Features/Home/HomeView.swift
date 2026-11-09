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
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(repository: repository)
        )
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Type Filter | 유형별 필터
            TypeFilter(
                selectedType: viewModel.selectedType,
                onSelect: { viewModel.selectedType = $0 }
            )

            ScrollView {
                VStack(spacing: AppSpacing.sectionSpacing) {

                    // MARK: - Month Calendar | 달력
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

                    // MARK: - Selected Date Events | 선택한 날짜의 일정
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

        // MARK: - Add Toolbar | 등록 화면 열기
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

        // MARK: - Registration | 등록 유형 선택 및 UseCase 주입
        .fullScreenCover(isPresented: $showsRegistrationTypeSelection) {
            NavigationStack {
                RegistrationTypeSelectionView()
            }

            // MARK: - Coupon | 쿠폰 저장
            .environment(
                \.saveCouponUseCase,
                SaveCouponUseCase(repository: repository)
            )
            .environment(\.onCouponSaved, { savedItem in
                viewModel.reload()

                if let expiryDate = savedItem.endDate {
                    viewModel.pickDate(expiryDate)
                }

                showsRegistrationTypeSelection = false
            })

            // MARK: - Pass | 이용권 저장
            .environment(
                \.savePassUseCase,
                SavePassUseCase(repository: repository)
            )
            .environment(\.onPassSaved, { savedItem in
                viewModel.reload()

                if let endDate = savedItem.endDate {
                    viewModel.pickDate(endDate)
                }

                showsRegistrationTypeSelection = false
            })

            // MARK: - Subscription | 정기 구독 저장
            .environment(
                \.saveSubscriptionUseCase,
                SaveSubscriptionUseCase(repository: repository)
            )
            .environment(\.onSubscriptionSaved, { savedItem in
                viewModel.reload()

                let today = Calendar.current.startOfDay(for: Date())
                let startDate = Calendar.current.startOfDay(for: savedItem.startDate)

                if startDate >= today {
                    viewModel.pickDate(startDate)
                } else if let nextBillingDate = savedItem.subscriptionCycle?
                    .upcomingBillingDates(from: startDate, count: 1).first {
                    viewModel.pickDate(nextBillingDate)
                } else {
                    viewModel.pickDate(startDate)
                }

                showsRegistrationTypeSelection = false
            })

            // MARK: - Schedule | 일정 저장
            .environment(
                \.saveScheduleUseCase,
                SaveScheduleUseCase(repository: repository)
            )
            .environment(\.onScheduleSaved, { savedItem in
                viewModel.reload()
                viewModel.pickDate(savedItem.startDate)
                showsRegistrationTypeSelection = false
            })
        }

        // MARK: - Temporary Detail | 상세 화면 미구현
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

// MARK: - Navigation Title Style | iOS 버전에 맞는 제목 표시
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
