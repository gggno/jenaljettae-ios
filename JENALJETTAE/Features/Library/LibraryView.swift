//
//  LibraryView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/14/26.
//

import SwiftUI

// MARK: - Library View | 보관 현황·검색·정렬·항목 목록
struct LibraryView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel: LibraryViewModel
    private let repository: any ManagedItemRepository

    @State private var selectedDetailID: UUID?
    @State private var showsDetail = false
    @State private var showsSortSheet = false
    @State private var visibleItemCount = 10
    private let initialVisibleCount = 10
    private let loadMoreCount = 15
    @FocusState private var isSearchFocused: Bool

    // MARK: - Dependency Injection | Repository로 보관함 ViewModel 생성
    init(repository: any ManagedItemRepository) {
        self.repository = repository
        _viewModel = StateObject(wrappedValue: LibraryViewModel(repository: repository))
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    LibrarySummaryView(
                        totalCount: viewModel.totalCount,
                        activeCount: viewModel.activeCount,
                        historyCount: viewModel.historyCount,
                        selectedScope: viewModel.selectedScope,
                        onSelect: selectScope
                    )

                    searchBar
                    typeFilter

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        listHeader
                            .id("library-list-header")
                        itemList
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.small)
                .padding(.bottom, AppSpacing.xxLarge)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { isSearchFocused = false }
                }
                .id("library-top")
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: visibleItemCount) { previousCount, currentCount in
                guard previousCount > initialVisibleCount && currentCount == initialVisibleCount else { return }

                DispatchQueue.main.async {
                    var transaction = Transaction(animation: nil)
                    transaction.disablesAnimations = true

                    withTransaction(transaction) {
                        scrollProxy.scrollTo("library-top", anchor: .top)
                    }
                }
            }
        }
        .sheet(isPresented: $showsSortSheet) { sortSheet }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("보관함")
        .modifier(LibraryNavigationTitleStyle())
        .navigationDestination(isPresented: $showsDetail) {
            if let selectedDetailID {
                ManagedItemDetailView(itemID: selectedDetailID, repository: repository, onItemChanged: { viewModel.reload() })
            }
        }
        .toolbar(showsDetail ? .hidden : .visible, for: .tabBar)
        .onAppear { viewModel.reload() }
        .onChange(of: viewModel.searchText) { _, _ in visibleItemCount = initialVisibleCount }
    }

    // MARK: - Scope Selection | 선택 카드만 애니메이션, 목록은 즉시 갱신
    private func selectScope(_ scope: LibraryScope) {
        guard viewModel.selectedScope != scope else { return }
        viewModel.selectedScope = scope
        visibleItemCount = initialVisibleCount
    }

    // MARK: - Search | 이름·브랜드·상세 정보 검색
    private var searchBar: some View {
        HStack(spacing: AppSpacing.xSmall) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColor.textSecondary)
            TextField("보관한 항목을 검색해 보세요", text: $viewModel.searchText)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isSearchFocused)
            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.textSecondary)
                }
                .accessibilityLabel("검색어 지우기")
            }
        }
        .padding(.horizontal, AppSpacing.small)
        .frame(height: 48)
        .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Type Filter | 유형을 화면에 항상 표시하고 즉시 필터링
    private var typeFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xSmall) {
                typeFilterButton(nil)
                typeFilterButton(.coupon)
                typeFilterButton(.pass)
                typeFilterButton(.subscription)
                typeFilterButton(.schedule)
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - Type Button | 선택 유형을 강조하고 목록 즉시 갱신
    private func typeFilterButton(_ type: ManagedItemType?) -> some View {
        let isSelected = viewModel.selectedType == type
        return Button {
            guard viewModel.selectedType != type else { return }
            viewModel.selectedType = type
            visibleItemCount = initialVisibleCount
        } label: {
            Text(type.map { viewModel.typeTitle($0) } ?? "전체")
                .font(AppTypography.caption.weight(isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? AppColor.onPrimary : AppColor.textSecondary)
                .padding(.horizontal, AppSpacing.small)
                .padding(.vertical, AppSpacing.xSmall)
                .background(isSelected ? AppColor.primary : AppColor.surface, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - List Header | 목록 수와 정렬 메뉴
    private var listHeader: some View {
        HStack(spacing: AppSpacing.xSmall) {
            Text("보관 목록")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)
            Text("\(viewModel.filteredItems.count)")
                .font(AppTypography.number)
                .foregroundStyle(AppColor.primaryForeground)
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: viewModel.filteredItems.count)
            Spacer(minLength: 0)
            Button { showsSortSheet = true } label: {
                HStack(spacing: AppSpacing.xxSmall) {
                    Image(systemName: "arrow.down.wide.short")
                    Text(viewModel.sortOrder.title)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
                .padding(.vertical, AppSpacing.xSmall)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("정렬 기준 선택")
        }
    }

    // MARK: - Sort Bottom Sheet | 고정된 내부 높이로 상하단 간격 최소화
    private var sortSheet: some View {
        VStack(spacing: 0) {
            // MARK: - Drag Indicator | 시스템 핸들과 중복되지 않도록 직접 배치
            Capsule()
                .fill(AppColor.disabledText.opacity(0.5))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 10)

            Text("정렬")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(LibrarySortOrder.allCases, id: \.self) { order in
                    Button {
                        viewModel.sortOrder = order
                        visibleItemCount = initialVisibleCount
                        showsSortSheet = false
                    } label: {
                        HStack {
                            Text(order.title)
                                .font(AppTypography.body)
                                .foregroundStyle(order == viewModel.sortOrder ? AppColor.primaryForeground : AppColor.textPrimary)

                            Spacer()

                            Image(systemName: order == viewModel.sortOrder ? "largecircle.fill.circle" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(order == viewModel.sortOrder ? AppColor.primaryForeground : AppColor.disabledText)
                        }
                        .frame(height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(order == viewModel.sortOrder ? .isSelected : [])
                }
            }
            .padding(.bottom, 8)

            Button { showsSortSheet = false } label: {
                Text("닫기")
                    .font(AppTypography.button)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppColor.surface, in: RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).strokeBorder(AppColor.border, lineWidth: 1) }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, 15)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .top)
        .presentationBackground(AppColor.background)
        .presentationDetents([.height(CGFloat(LibrarySortOrder.allCases.count) * 44 + 122)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(22)
    }

    // MARK: - Item List | 접을 때 목록을 다시 구성해 표시 오류 방지
    private var itemList: some View {
        listContent(viewModel.filteredItems)
            .id(visibleItemCount == initialVisibleCount)
    }

    @ViewBuilder
    private func listContent(_ filteredItems: [ManagedItem]) -> some View {
        if let error = viewModel.errorMessage {
            ContentUnavailableView("보관함을 불러올 수 없어요", systemImage: "exclamationmark.circle", description: Text(error))
        } else if filteredItems.isEmpty {
            ContentUnavailableView(
                viewModel.items.isEmpty ? "보관한 항목이 없어요" : "조건에 맞는 항목이 없어요",
                systemImage: viewModel.items.isEmpty ? "archivebox" : "magnifyingglass",
                description: Text(viewModel.items.isEmpty ? "홈에서 새로운 항목을 등록해 주세요." : "검색어나 항목 유형을 확인해 주세요.")
            )
        } else {
            let visibleItems = Array(filteredItems.prefix(visibleItemCount))
            let remainingCount = max(0, filteredItems.count - visibleItems.count)
            VStack(spacing: 0) {
                ForEach(visibleItems) { item in
                    Button {
                        selectedDetailID = item.id
                        showsDetail = true
                    } label: {
                        LibraryItemRow(item: item, subtitle: viewModel.subtitle(for: item), status: viewModel.status(for: item), isArchived: viewModel.isArchived(item))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(item.title), \(viewModel.status(for: item)), 상세 정보 보기")
                    if item.id != visibleItems.last?.id {
                        Rectangle().fill(AppColor.border.opacity(0.5)).frame(height: 1)
                    }
                }
                if filteredItems.count > initialVisibleCount {
                    HStack(spacing: AppSpacing.small) {
                        if remainingCount > 0 {
                            listActionButton(title: "\(min(loadMoreCount, remainingCount))개 더 보기", icon: "chevron.down") {
                                visibleItemCount = min(visibleItemCount + loadMoreCount, filteredItems.count)
                            }
                        }

                        if visibleItemCount > initialVisibleCount {
                            listActionButton(title: "접기", icon: "chevron.up") {
                                visibleItemCount = initialVisibleCount
                            }
                        }
                    }
                    .padding(.top, AppSpacing.small)
                }
            }
        }
    }

    // MARK: - List Action | 목록 버튼 전체를 터치 영역으로 사용
    private func listActionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xSmall) {
                Text(title)
                Image(systemName: icon)
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColor.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - Navigation Title Style | 홈과 동일한 타이틀 표시 방식
private struct LibraryNavigationTitleStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.toolbarTitleDisplayMode(.inlineLarge) }
        else { content.navigationBarTitleDisplayMode(.large) }
    }
}

// MARK: - Preview | 샘플 보관함
#Preview {
    NavigationStack { LibraryView(repository: SampleManagedItemRepository()) }
}
