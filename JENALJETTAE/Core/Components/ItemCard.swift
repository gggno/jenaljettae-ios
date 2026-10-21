import SwiftUI

// MARK: - Item Card Mode

enum ItemCardMode {
    case record
    case typeSelection
}

// MARK: - Item Card

struct ItemCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let statusLabel: String
    var statusTone: StatusBadgeTone = .neutral
    var mode: ItemCardMode = .record
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.small) {

                // MARK: - Item Icon

                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColor.primaryForeground)
                    .frame(width: 24, height: 24)
                    .frame(width: 42, height: 42)
                    .background(AppColor.primaryTint, in: RoundedRectangle(cornerRadius: AppRadius.input))
                    .accessibilityHidden(true)

                // MARK: - Item Information

                VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                    Text(title)
                        .font(AppTypography.itemTitle)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: AppSpacing.xSmall)

                // MARK: - Right Accessory

                switch mode {
                case .record:
                    StatusBadge(label: statusLabel, tone: statusTone)

                case .typeSelection:
                    Image("ic_jnt_chevron_right")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: 16, height: 16)
                        .accessibilityHidden(true)
                }
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.card, in: RoundedRectangle(cornerRadius: AppRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .strokeBorder(AppColor.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Content

private struct ItemCardPreview: View {
    var body: some View {
        VStack(spacing: AppSpacing.cardSpacing) {
            ItemCard(
                title: "아메리카노 교환권",
                subtitle: "쿠폰 · 만료 10.20",
                iconName: "ic_jnt_coupon",
                statusLabel: "D-6",
                statusTone: .attention
            ) {
                print("ItemCard - 쿠폰 카드 클릭")
            }

            ItemCard(
                title: "헤어 커트 예약",
                subtitle: "예약 · 10.21 15:00",
                iconName: "ic_jnt_reservation",
                statusLabel: "예정"
            ) {
                print("ItemCard - 예약 카드 클릭")
            }

            ItemCard(
                title: "쿠폰·기프티콘",
                subtitle: "상품 교환권, 할인 쿠폰",
                iconName: "ic_jnt_coupon",
                statusLabel: "",
                mode: .typeSelection
            ) {
                print("ItemCard - 유형 선택")
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColor.background.ignoresSafeArea())
    }
}

// MARK: - Light / Dark Preview

#Preview("Light") {
    ItemCardPreview()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ItemCardPreview()
        .preferredColorScheme(.dark)
}
