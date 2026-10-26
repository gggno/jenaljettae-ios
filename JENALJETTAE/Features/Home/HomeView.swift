//
//  HomeView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

// MARK: - Home View | UI 표시 및 사용자 입력을 ViewModel에 전달
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    // MARK: - Dependency Injection | 외부에서 전달한 Repository로 ViewModel 생성
    init(repository: any ManagedItemRepository) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
    }
    @State private var showsRegistrationTypeSelection = false
    @State private var showsSampleDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Type Filter | 선택한 카테고리를 ViewModel에 반영
            TypeFilter(selectedType: viewModel.selectedType, onSelect: { viewModel.selectedType = $0 })

            ScrollView {
                VStack(spacing: AppSpacing.sectionSpacing) {
                    
                    // MARK: - Month Calendar | ViewModel의 일정과 날짜 이동 기능 연결
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

                    // MARK: - Selected Date Events | 선택 날짜에 해당하는 일정만 표시
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

        // MARK: - Registration | + 버튼 클릭 시 등록 유형 선택 화면 열기
        .fullScreenCover(isPresented: $showsRegistrationTypeSelection) {
            NavigationStack {
                RegistrationTypeSelectionView()
            }
        }

        // MARK: - Alert | 상세 기능 구현 전 임시 안내 표시
        .alert("일정 상세 화면 준비 중", isPresented: $showsSampleDetail) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("현재는 UI 확인용 예시 일정이에요.")
        }
    }

    // MARK: - Add Toolbar Button | 기존 등록 화면 이동 기능 유지
    private var addToolbarButton: some View {
        Button {
            showsRegistrationTypeSelection = true
        } label: {
            Label("항목 추가", image: AppIcon.add)
        }
        .tint(AppColor.textPrimary)
    }
}

// MARK: - Navigation Title Style | iOS 버전에 맞는 제목 표시 방식 적용
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

// MARK: - Scroll Edge Style | iOS 26 이상에서 기존 상단 효과 숨김 유지
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

// MARK: - Preview | 네비게이션 타이틀과 툴바 포함 확인
#Preview {
    NavigationStack {
        HomeView(repository: SampleManagedItemRepository())
    }
}
