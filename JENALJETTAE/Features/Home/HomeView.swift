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
    @State private var selectedDetailID: UUID?
    @State private var showsDetail = false

    // MARK: - Dependency Injection | Repository로 홈 ViewModel 생성
    init(repository: any ManagedItemRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Type Filter | 선택 유형에 맞게 달력 및 목록 갱신
            TypeFilter(selectedType: viewModel.selectedType, onSelect: { viewModel.selectedType = $0 })

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
                        onEventTap: { id in
                            selectedDetailID = id
                            showsDetail = true
                        }
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

        // MARK: - Add Toolbar | 기존 버튼 위치 유지
        .toolbar {
            if #available(iOS 27.1, *) {
                ToolbarItem(placement: .topBarPinnedTrailing) { addToolbarButton }
                    .axisBehavior(.verticalPreferred)
                    .visibilityPriority(.high)
            } else {
                ToolbarItem(placement: .topBarTrailing) { addToolbarButton }
            }
        }

        // MARK: - Registration | 쿠폰·이용권·구독·일정 등록 유지
        .fullScreenCover(isPresented: $showsRegistrationTypeSelection) {
            NavigationStack { RegistrationTypeSelectionView() }
                .environment(\.saveCouponUseCase, SaveCouponUseCase(repository: repository))
                .environment(\.onCouponSaved, { savedItem in
                    viewModel.reload()
                    if let expiryDate = savedItem.endDate { viewModel.pickDate(expiryDate) }
                    showsRegistrationTypeSelection = false
                })
                .environment(\.savePassUseCase, SavePassUseCase(repository: repository))
                .environment(\.onPassSaved, { savedItem in
                    viewModel.reload()
                    if let endDate = savedItem.endDate { viewModel.pickDate(endDate) }
                    showsRegistrationTypeSelection = false
                })
                .environment(\.saveSubscriptionUseCase, SaveSubscriptionUseCase(repository: repository))
                .environment(\.onSubscriptionSaved, { savedItem in
                    viewModel.reload()

                    // MARK: - Subscription Navigation | 시작일 또는 다음 예정 결제일
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
                .environment(\.saveScheduleUseCase, SaveScheduleUseCase(repository: repository))
                .environment(\.onScheduleSaved, { savedItem in
                    viewModel.reload()
                    viewModel.pickDate(savedItem.startDate)
                    showsRegistrationTypeSelection = false
                })
        }

        // MARK: - Item Detail | 선택한 항목을 ID로 조회하여 표시
        .navigationDestination(isPresented: $showsDetail) {
            if let selectedDetailID {
                ManagedItemDetailView(itemID: selectedDetailID, repository: repository)
            }
        }
        .toolbar(showsDetail ? .hidden : .visible, for: .tabBar)
    }

    // MARK: - Add Toolbar Button | 등록 유형 선택 화면 열기
    private var addToolbarButton: some View {
        Button { showsRegistrationTypeSelection = true } label: { Label("항목 추가", image: AppIcon.add) }
            .tint(AppColor.textPrimary)
    }
}

// MARK: - Navigation Title Style | iOS 버전에 맞는 제목 표시 방식
private struct HomeNavigationTitleStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.toolbarTitleDisplayMode(.inlineLarge) }
        else { content.navigationBarTitleDisplayMode(.large) }
    }
}

// MARK: - Scroll Edge Style | iOS 26 이상 상단 스크롤 효과 제거
private struct HomeScrollEdgeStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.scrollEdgeEffectHidden(true, for: .top) }
        else { content }
    }
}

// MARK: - Preview | 홈 화면 미리보기
#Preview {
    NavigationStack { HomeView(repository: SampleManagedItemRepository()) }
}
