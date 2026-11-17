//
//  ManagedItemDetailView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/9/26.
//

import SwiftUI
import UIKit

// MARK: - Managed Item Detail View | 포인트 카드형 상세 화면
struct ManagedItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ManagedItemDetailViewModel
    private let repository: any ManagedItemRepository
    private let onItemChanged: () -> Void
    @State private var showsEditScreen = false
    @State private var showsDeleteConfirmation = false
    @State private var showsDeleteError = false
    @State private var deleteErrorMessage = ""
    @State private var showsImagePreview = false
    @State private var showsCopyNotice = false

    init(itemID: UUID, repository: any ManagedItemRepository, onItemChanged: @escaping () -> Void = {}) {
        self.repository = repository
        self.onItemChanged = onItemChanged
        _viewModel = StateObject(wrappedValue: ManagedItemDetailViewModel(itemID: itemID, repository: repository))
    }

    var body: some View {
        ScrollView {
            Group {
                if let item = viewModel.item {
                    detailContent(for: item)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView("상세 정보를 불러올 수 없어요", systemImage: "exclamationmark.circle", description: Text(errorMessage))
                        .padding(.top, AppSpacing.xxLarge)
                } else {
                    ProgressView().padding(.top, AppSpacing.xxLarge)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("상세 정보")
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - Edit & Delete | 기존 상세화면 상단 액션
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.item != nil {
                    Menu {
                        Button { showsEditScreen = true } label: { Label("수정", systemImage: "pencil") }
                        Button(role: .destructive) { showsDeleteConfirmation = true } label: { Label("삭제", systemImage: "trash") }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .accessibilityLabel("항목 관리")
                }
            }
        }
        // MARK: - Edit Registration | 유형별 기존 등록 화면을 수정 모드로 재사용
        .sheet(isPresented: $showsEditScreen) {
            if let item = viewModel.item {
                NavigationStack {
                    editRegistrationView(for: item)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("취소") { showsEditScreen = false }
                            }
                        }
                }
                .environment(\.saveCouponUseCase, SaveCouponUseCase(repository: repository))
                .environment(\.onCouponSaved, { _ in finishEditing() })
                .environment(\.savePassUseCase, SavePassUseCase(repository: repository))
                .environment(\.onPassSaved, { _ in finishEditing() })
                .environment(\.saveSubscriptionUseCase, SaveSubscriptionUseCase(repository: repository))
                .environment(\.onSubscriptionSaved, { _ in finishEditing() })
                .environment(\.saveScheduleUseCase, SaveScheduleUseCase(repository: repository))
                .environment(\.onScheduleSaved, { _ in finishEditing() })
            }
        }
        .alert("항목을 삭제할까요?", isPresented: $showsDeleteConfirmation) {
            Button("삭제", role: .destructive) { deleteCurrentItem() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 항목은 복구할 수 없어요.")
        }
        .alert("삭제할 수 없어요", isPresented: $showsDeleteError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage)
        }
        .onAppear { viewModel.load() }
        .fullScreenCover(isPresented: $showsImagePreview) {
            if let data = viewModel.item?.imageData, let image = UIImage(data: data) {
                RegistrationImagePreviewView(image: image)
            }
        }
        .alert("번호를 복사했어요", isPresented: $showsCopyNotice) {
            Button("확인", role: .cancel) {}
        }
    }

    // MARK: - Edit Destination | 등록 UI를 그대로 사용하되 원본 데이터를 전달
    @ViewBuilder
    private func editRegistrationView(for item: ManagedItem) -> some View {
        switch item.type {
        case .coupon: CouponManualEntryView(editingItem: item)
        case .pass: PassManualEntryView(editingItem: item)
        case .subscription: SubscriptionManualEntryView(editingItem: item)
        case .schedule: ScheduleManualEntryView(editingItem: item)
        }
    }

    // MARK: - Edit Complete | 상세 데이터와 홈 목록 새로고침
    @MainActor
    private func finishEditing() {
        viewModel.load()
        onItemChanged()
        showsEditScreen = false
    }

    // MARK: - Delete Item | 저장소 삭제 성공 후 홈으로 복귀
    @MainActor
    private func deleteCurrentItem() {
        guard let item = viewModel.item else { return }
        do {
            try repository.deleteItem(id: item.id)
            onItemChanged()
            dismiss()
        } catch {
            deleteErrorMessage = error.localizedDescription
            showsDeleteError = true
        }
    }

    // MARK: - Content | 실제 저장된 값만 노출
    private func detailContent(for item: ManagedItem) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            pointCard(for: item)
            additionalSection(for: item)

            if item.type == .subscription, let cycle = item.subscriptionCycle {
                billingSection(startDate: item.startDate, cycle: cycle)
            }

            imageSection(for: item)

            if let memo = nonEmpty(item.memo) {
                section(title: "메모") {
                    Text(memo)
                        .font(.subheadline)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.large)
        .padding(.bottom, AppSpacing.xxLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Image | 이미지 선택값이 있을 때만 표시
    @ViewBuilder
    private func imageSection(for item: ManagedItem) -> some View {
        if let data = item.imageData, let image = UIImage(data: data) {
            Button { showsImagePreview = true } label: {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 224)
                    .background(AppColor.inputSurface, in: RoundedRectangle(cornerRadius: AppRadius.largeCard))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.largeCard))
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColor.textPrimary)
                            .padding(10)
                            .background(AppColor.card, in: Circle())
                            .padding(AppSpacing.small)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("등록된 이미지 크게 보기")
        }
    }

    // MARK: - Point Card | 제목 옆 상태 배지 + 유형·사용처 + 핵심 정보
    private func pointCard(for item: ManagedItem) -> some View {
        let countdown = countdown(for: item)
        let subtitle = [typeTitle(for: item.type), nonEmpty(item.detail)].compactMap { $0 }.joined(separator: " · ")

        return VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .top, spacing: AppSpacing.small) {
                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                    // MARK: - Title Badge | 공간이 좁으면 배지를 제목 아래에 표시
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .center, spacing: AppSpacing.small) {
                            Text(item.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(AppColor.textPrimary)
                                .fixedSize(horizontal: true, vertical: true)

                            statusBadge(countdown.value)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text(item.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(AppColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            statusBadge(countdown.value)
                        }
                    }

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColor.primary)
                        .frame(width: 5)
                }

                Image(itemIcon(for: item.type))
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 21, height: 21)
                    .foregroundStyle(AppColor.primaryForeground)
                    .frame(width: 44, height: 44)
                    .background(AppColor.primaryTint, in: RoundedRectangle(cornerRadius: AppRadius.input))
            }

            Rectangle().fill(AppColor.border).frame(height: 1)
            primaryMetrics(for: item)

            if item.type != .coupon, let timeline = periodTimeline(for: item) {
                Rectangle().fill(AppColor.border).frame(height: 1)
                periodTimelineView(timeline)
            }
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.largeCard))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.largeCard)
                .strokeBorder(AppColor.border, lineWidth: 1)
        }
    }

    // MARK: - Status Badge | 유형별 D-day 또는 상태를 제목 옆에 표시
    private func statusBadge(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(AppColor.primaryForeground)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColor.primaryTint, in: RoundedRectangle(cornerRadius: 7))
    }

    // MARK: - Primary Metrics | 타입별 핵심 날짜/기간
    @ViewBuilder
    private func primaryMetrics(for item: ManagedItem) -> some View {
        switch item.type {
        case .coupon:
            metric(label: "만료일", value: dateTextWithWeekday(item.endDate ?? item.startDate))

        case .pass:
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                metric(label: "시작일", value: dateText(item.startDate))
                metric(label: "종료일", value: dateText(item.endDate ?? item.startDate))
            }
            durationCaption(for: item)

        case .subscription:
            HStack(alignment: .top, spacing: AppSpacing.medium) {
                metric(label: "구독 시작일", value: dateText(item.startDate))
                if let nextDate = nextBillingDate(for: item) {
                    metric(label: "다음 결제일", value: dateText(nextDate))
                }
            }
            if let cycle = item.subscriptionCycle {
                Label("\(cycle.title) 반복 결제", systemImage: "arrow.triangle.2.circlepath")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

        case .schedule:
            if let endDate = item.endDate, !Calendar.current.isDate(endDate, inSameDayAs: item.startDate) {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    metric(label: "시작일", value: dateText(item.startDate))
                    metric(label: "종료일", value: dateText(endDate))
                }
                durationCaption(for: item)
            } else {
                metric(label: "일정일", value: dateTextWithWeekday(item.startDate))
            }
        }
    }

    private func metric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func durationCaption(for item: ManagedItem) -> some View {
        Label("총 \(durationText(for: item))", systemImage: "calendar")
            .font(AppTypography.caption)
            .foregroundStyle(AppColor.textSecondary)
    }

    // MARK: - Period Timeline | 현재 위치 포인트형 프로그레스 바
    private enum PeriodPhase: Equatable {
        case upcoming    // 시작 전: 빈 트랙과 시작 위치 포인트
        case ongoing     // 진행 중: 진행률만큼 채움
        case lastDay     // 종료/결제 예정일: 100% 채움과 완료 포인트
        case ended       // 종료 후: 100% 채움과 종료 상태
    }

    private struct PeriodTimeline {
        let status: String
        let detail: String
        let progress: Double
        let phase: PeriodPhase
    }

    private func periodTimelineView(_ timeline: PeriodTimeline) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                Text(timeline.status)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.primaryForeground)

                Spacer(minLength: 0)

                Text(timeline.detail)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            PeriodProgressTrack(progress: timeline.progress, phase: timeline.phase)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(timeline.status), \(timeline.detail)")
        }
    }

    // MARK: - Progress Track | 10pt 바 + 20pt 현재 위치 포인트
    private struct PeriodProgressTrack: View {
        let progress: Double
        let phase: PeriodPhase

        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @State private var displayedProgress: Double = 0
        @State private var showsCheckmark = false
        @State private var animationVersion = 0

        private struct TrackInput: Equatable {
            let progress: Double
            let phase: PeriodPhase
            let reduceMotion: Bool
        }

        private var trackInput: TrackInput {
            TrackInput(progress: progress, phase: phase, reduceMotion: reduceMotion)
        }

        private let trackHeight: CGFloat = 10
        private let markerSize: CGFloat = 20

        var body: some View {
            GeometryReader { geometry in
                let width = geometry.size.width
                let clampedProgress = min(1, max(0, displayedProgress))

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.primaryTint)
                        .frame(height: trackHeight)

                    Capsule()
                        .fill(AppColor.primary)
                        .frame(width: width * clampedProgress, height: trackHeight)

                    Circle()
                        .fill(AppColor.primary)
                        .frame(width: markerSize, height: markerSize)
                        .overlay { Circle().strokeBorder(AppColor.card, lineWidth: 3) }
                        .overlay {
                            if showsCheckmark {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(AppColor.onPrimary)
                                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                            }
                        }
                        .offset(x: max(0, width - markerSize) * clampedProgress)
                }
                .frame(height: markerSize)
            }
            .frame(height: markerSize)
            .onAppear { updateProgress() }
            .onChange(of: trackInput) { _, _ in updateProgress() }
        }

        private func updateProgress() {
            animationVersion += 1
            let version = animationVersion
            let target = min(1, max(0, progress))
            let shouldShowCheckmark = target >= 1 && (phase == .lastDay || phase == .ended)
            showsCheckmark = false

            if reduceMotion {
                displayedProgress = target
                showsCheckmark = shouldShowCheckmark
                return
            }

            // 막대가 끝까지 움직인 뒤 체크 아이콘을 나타냄
            withAnimation(.easeOut(duration: 0.7), completionCriteria: .removed) {
                displayedProgress = target
            } completion: {
                guard version == animationVersion, shouldShowCheckmark else { return }
                withAnimation(.easeOut(duration: 0.2)) { showsCheckmark = true }
            }
        }
    }

    // MARK: - Period Calculation | 쿠폰 제외, 일정·이용권·구독 기간 계산
    private func periodTimeline(for item: ManagedItem) -> PeriodTimeline? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: item.startDate)

        // 쿠폰은 기존 결정대로 타임라인을 표시하지 않음
        if item.type == .coupon { return nil }

        let startName: String
        let endName: String
        var from = start
        let to: Date

        switch item.type {
        case .coupon:
            return nil

        case .pass:
            guard let endDate = item.endDate else { return nil }
            to = calendar.startOfDay(for: endDate)
            startName = "이용"
            endName = "이용"

        case .schedule:
            // 하루짜리 일정은 기존과 동일하게 타임라인 생략
            guard let endDate = item.endDate, !calendar.isDate(endDate, inSameDayAs: item.startDate) else { return nil }
            to = calendar.startOfDay(for: endDate)
            startName = "일정"
            endName = "일정"

        case .subscription:
            guard let cycle = item.subscriptionCycle else { return nil }
            startName = "구독"
            endName = "결제"

            if today < start {
                // 첫 결제/시작 전: 구독 시작일까지 빈 트랙으로 표시
                return PeriodTimeline(status: "구독 시작 전", detail: "D-\(calendar.dateComponents([.day], from: today, to: start).day ?? 0)", progress: 0, phase: .upcoming)
            }

            // 구독 시작일은 최초 결제일이므로, 이후 반복 결제일을 기준으로 계산
            guard let nextDate = cycle.upcomingBillingDates(from: item.startDate, count: 1, referenceDate: today).first else { return nil }
            to = calendar.startOfDay(for: nextDate)

            guard let nextMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: to)),
                  let previousMonth = calendar.date(byAdding: .month, value: -cycle.intervalMonths, to: nextMonth),
                  let previousBillingDate = cycle.billingDate(from: item.startDate, in: previousMonth) else { return nil }
            from = max(start, calendar.startOfDay(for: previousBillingDate))
        }

        guard to >= from else { return nil }
        let remaining = max(0, calendar.dateComponents([.day], from: today, to: to).day ?? 0)

        if today < from {
            let days = calendar.dateComponents([.day], from: today, to: from).day ?? 0
            return PeriodTimeline(status: "\(startName) 시작 전", detail: "D-\(days)", progress: 0, phase: .upcoming)
        }

        if today > to {
            return PeriodTimeline(status: "\(endName) 종료", detail: "100%", progress: 1, phase: .ended)
        }

        if today == to {
            let status = item.type == .subscription ? "오늘 결제 예정" : "오늘 종료"
            return PeriodTimeline(status: status, detail: "100%", progress: 1, phase: .lastDay)
        }

        let total = calendar.dateComponents([.day], from: from, to: to).day ?? 0
        let elapsed = calendar.dateComponents([.day], from: from, to: today).day ?? 0
        let progress = total > 0 ? min(1, max(0, Double(elapsed) / Double(total))) : 0
        let percent = Int((progress * 100).rounded())
        let suffix = item.type == .subscription ? "결제까지 \(remaining)일" : "\(remaining)일 남음"
        return PeriodTimeline(status: "\(percent)% 진행", detail: suffix, progress: progress, phase: .ongoing)
    }

    // MARK: - Optional Information | 값이 없는 항목과 빈 카드는 만들지 않음
    @ViewBuilder
    private func additionalSection(for item: ManagedItem) -> some View {
        switch item.type {
        case .coupon:
            if let number = nonEmpty(item.couponNumber) {
                section(title: "쿠폰 번호", compact: true) {
                    copyableNumber(label: "쿠폰 번호", number: number, showsLabel: false)
                }
            }

        case .pass:
            if let number = nonEmpty(item.couponNumber) {
                section(title: "이용권 정보", icon: "ticket") {
                    copyableNumber(label: "이용권 번호", number: number)
                }
            }

        case .subscription:
            if let amount = item.subscriptionAmount {
                section(title: "결제 정보", icon: "creditcard") {
                    informationRow(label: "결제 금액", value: "\(amount.formatted())원")
                }
            }

        case .schedule:
            if let minutes = item.scheduleTimeMinutes {
                section(title: "일정 정보", icon: "clock") {
                    informationRow(label: "시작 시간", value: timeText(minutes))
                }
            }
        }
    }

    // MARK: - Billing Timeline | 구독 등록 화면과 동일한 세로 타임라인 UI
    private func billingSection(startDate: Date, cycle: SubscriptionCycle) -> some View {
        let dates = cycle.upcomingBillingDates(from: startDate, count: 3)

        return VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack {
                Text("예상 결제 일정")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Image(systemName: "calendar.clock")
                    .foregroundStyle(AppColor.primaryForeground)
            }

            VStack(spacing: 0) {
                ForEach(dates.indices, id: \.self) { index in
                    let date = dates[index]
                    let isNext = index == 0
                    let isLast = index == dates.count - 1

                    HStack(alignment: .top, spacing: AppSpacing.small) {
                        // MARK: - Timeline Indicator | 다음 결제일 강조 + 연결선
                        VStack(spacing: 0) {
                            Circle()
                                .fill(isNext ? AppColor.primary : AppColor.border)
                                .frame(width: isNext ? 12 : 10, height: isNext ? 12 : 10)
                                .frame(height: 14)

                            if !isLast {
                                Rectangle()
                                    .fill(AppColor.border)
                                    .frame(width: 2, height: 46)
                            }
                        }
                        .frame(width: 16)

                        // MARK: - Timeline Content | 결제일, 요일 및 월말 보정 여부
                        VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xSmall) {
                                Text(dateText(date))
                                    .font(.subheadline.weight(isNext ? .semibold : .medium))
                                    .foregroundStyle(AppColor.textPrimary)

                                Spacer(minLength: 0)

                                if isNext {
                                    Text("다음 결제")
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppColor.primaryForeground)
                                }
                            }

                            Text(billingDateDetail(date, startDate: startDate))
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColor.textSecondary)
                        }
                    }
                }
            }

            Text("실제 결제일은 서비스 정책에 따라 달라질 수 있어요.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Billing Date Detail | 요일 및 월말 보정 여부 표시
    private func billingDateDetail(_ date: Date, startDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: date)
        let calendar = Calendar.current
        let startDay = calendar.component(.day, from: startDate)
        let billingDay = calendar.component(.day, from: date)
        return billingDay < startDay ? "\(weekday) · 월말 보정" : weekday
    }

    // MARK: - Shared Cards | 부가 정보 및 메모
    private func section<Content: View>(title: String, icon: String? = nil, compact: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Group {
                if let icon {
                    Label(title, systemImage: icon)
                } else {
                    Text(title)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppColor.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                content()
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, compact ? AppSpacing.xSmall : AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.card))
        }
    }

    private func informationRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.medium) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            Spacer(minLength: 0)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func copyableNumber(label: String, number: String, showsLabel: Bool = true) -> some View {
        HStack(spacing: AppSpacing.small) {
            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                if showsLabel {
                    Text(label)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Text(number)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(AppColor.textPrimary)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 0)

            Button {
                UIPasteboard.general.string = number
                showsCopyNotice = true
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppColor.primaryForeground)
                    .frame(width: 40, height: 40)
                    .background(AppColor.primaryTint, in: RoundedRectangle(cornerRadius: AppRadius.input))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(label) 복사")
        }
    }

    // MARK: - Countdown | 모든 유형의 D-day 계산
    private func countdown(for item: ManagedItem) -> (label: String, value: String) {
        let today = Calendar.current.startOfDay(for: Date())
        let start = Calendar.current.startOfDay(for: item.startDate)
        let end = Calendar.current.startOfDay(for: item.endDate ?? item.startDate)

        switch item.type {
        case .coupon:
            if end < today { return ("쿠폰 만료", "만료") }
            return ("만료일까지", dayCount(to: end))

        case .pass:
            if start > today { return ("이용 시작까지", dayCount(to: start)) }
            if end < today { return ("이용 종료", "종료") }
            return ("이용 진행 중", "진행중")

        case .subscription:
            if start > today { return ("구독 시작까지", dayCount(to: start)) }
            if start == today { return ("구독 시작일", "오늘 구독 시작") }
            if let nextDate = nextBillingDate(for: item), Calendar.current.isDate(nextDate, inSameDayAs: today) {
                return ("구독 갱신 예정", "오늘 갱신 예정")
            }
            return ("구독 상태", "구독중")

        case .schedule:
            if start > today { return ("일정 시작까지", dayCount(to: start)) }
            if end < today { return ("일정 종료", "종료") }
            return ("일정 진행 중", "진행중")
        }
    }

    private func dayCount(to target: Date) -> String {
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: target)).day ?? 0
        if difference == 0 { return "D-DAY" }
        return difference > 0 ? "D-\(difference)" : "D+\(-difference)"
    }

    private func nextBillingDate(for item: ManagedItem) -> Date? {
        guard item.type == .subscription else { return nil }
        if Calendar.current.startOfDay(for: item.startDate) >= Calendar.current.startOfDay(for: Date()) { return item.startDate }
        return item.subscriptionCycle?.upcomingBillingDates(from: item.startDate, count: 1).first
    }

    // MARK: - Text | 선택값은 trim 처리하고 공백이면 미표시
    private func nonEmpty(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else { return nil }
        return value
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    private func dateTextWithWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd (EEE)"
        return formatter.string(from: date)
    }

    private func timeText(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    private func durationText(for item: ManagedItem) -> String {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: item.startDate)
        let end = calendar.startOfDay(for: item.endDate ?? item.startDate)
        let days = max(1, (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1)
        return days == 1 ? "1일" : "\(days)일"
    }

    // MARK: - Type | 홈 화면과 같은 유형 이름
    private func typeTitle(for type: ManagedItemType) -> String {
        switch type {
        case .coupon: return "쿠폰"
        case .pass: return "이용권"
        case .subscription: return "구독"
        case .schedule: return "일정"
        }
    }

    // MARK: - Icons | 홈 화면과 같은 유형별 아이콘 이미지
    private func itemIcon(for type: ManagedItemType) -> String {
        switch type {
        case .coupon: return "ic_jnt_coupon"
        case .pass: return "ic_jnt_pass"
        case .subscription: return "ic_jnt_subscription"
        case .schedule: return "ic_jnt_schedule"
        }
    }
}
