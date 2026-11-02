//
//  CouponImagePreviewView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/2/26.
//

import SwiftUI
import UIKit

// MARK: - Coupon Image Preview | 전체 화면 이미지 확인 및 드래그로 닫기
struct CouponImagePreviewView: View {
    let image: UIImage

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Close Button | 이미지와 겹치지 않는 상단 닫기 버튼
            HStack {
                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(AppColor.card, in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(AppColor.border, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("이미지 닫기")
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.small)
            .padding(.bottom, AppSpacing.large)

            // MARK: - Zoomable Image | 실제 이미지 모서리에 라운드를 적용하여 표시
            ZoomableCouponImage(image: image, onDismiss: { dismiss() })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.medium)
        }
        .background(AppColor.background.ignoresSafeArea())
    }
}

// MARK: - Zoomable Coupon Image | UIScrollView 기반 이미지 확대·축소 및 닫기
private struct ZoomableCouponImage: UIViewRepresentable {
    let image: UIImage
    let onDismiss: () -> Void

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.bouncesZoom = true
        scrollView.bounces = false
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.panGestureRecognizer.isEnabled = false

        // MARK: - Image View | 원본 비율을 유지하면서 실제 이미지 모서리만 둥글게 표시
        let imageView = RoundedCouponImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        context.coordinator.imageView = imageView

        // MARK: - Double Tap | 더블탭으로 이미지 확대·축소
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        // MARK: - Dismiss Pan | 아래로 드래그해 전체 화면 닫기
        let dismissPan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDismissPan(_:)))
        dismissPan.maximumNumberOfTouches = 1
        dismissPan.delegate = context.coordinator
        scrollView.addGestureRecognizer(dismissPan)

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.imageView?.image = image
        context.coordinator.imageView?.setNeedsLayout()
        context.coordinator.onDismiss = onDismiss
    }

    func makeCoordinator() -> Coordinator { Coordinator(onDismiss: onDismiss) }

    // MARK: - Coordinator | 이미지 확대 및 아래 방향 드래그 관리
    final class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        weak var imageView: UIImageView?
        var onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        // MARK: - Image Zoom | 확대된 상태에서만 이미지 이동 허용
        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            scrollView.panGestureRecognizer.isEnabled = scrollView.zoomScale > scrollView.minimumZoomScale + 0.01
        }

        // MARK: - Double Tap | 누른 위치 기준으로 2.5배 확대 또는 복귀
        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView = recognizer.view as? UIScrollView, let imageView else { return }

            if scrollView.zoomScale > 1.01 {
                scrollView.setZoomScale(1, animated: true)
                return
            }

            let zoom: CGFloat = 2.5
            let location = recognizer.location(in: imageView)
            let size = CGSize(width: scrollView.bounds.width / zoom, height: scrollView.bounds.height / zoom)
            let rect = CGRect(
                x: location.x - size.width / 2,
                y: location.y - size.height / 2,
                width: size.width,
                height: size.height
            )

            scrollView.zoom(to: rect, animated: true)
        }

        // MARK: - Dismiss Pan | 아래로 120pt 이상 드래그 시 화면 닫기
        @objc func handleDismissPan(_ recognizer: UIPanGestureRecognizer) {
            guard let scrollView = recognizer.view as? UIScrollView else { return }

            let translation = recognizer.translation(in: scrollView.superview)

            switch recognizer.state {
            case .changed:
                scrollView.transform = CGAffineTransform(translationX: 0, y: max(0, translation.y))

            case .ended:
                if translation.y >= 120 {
                    onDismiss()
                } else {
                    resetPosition(scrollView)
                }

            case .cancelled, .failed:
                resetPosition(scrollView)

            default:
                break
            }
        }

        // MARK: - Gesture Validation | 원본 크기에서 아래 방향 드래그만 허용
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
                  let scrollView = pan.view as? UIScrollView,
                  scrollView.zoomScale <= scrollView.minimumZoomScale + 0.01 else { return false }

            let velocity = pan.velocity(in: scrollView)
            return velocity.y > 0 && velocity.y > abs(velocity.x)
        }

        // MARK: - Reset Position | 기준 거리 미달 시 이미지 원위치
        private func resetPosition(_ scrollView: UIScrollView) {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                scrollView.transform = .identity
            }
        }
    }
}

// MARK: - Rounded Coupon Image View | 실제 표시되는 이미지 영역에만 라운드 적용
private final class RoundedCouponImageView: UIImageView {
    private let roundedMask = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let image,
              bounds.width > 0, bounds.height > 0,
              image.size.width > 0, image.size.height > 0 else { return }

        // MARK: - Aspect Fit Rect | 원본 비율 기준으로 실제 이미지 표시 영역 계산
        let scale = min(bounds.width / image.size.width, bounds.height / image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale

        let imageRect = CGRect(
            x: (bounds.width - width) / 2,
            y: (bounds.height - height) / 2,
            width: width,
            height: height
        )

        // MARK: - Rounded Image Mask | 이미지 실제 네 모서리만 둥글게 자르기
        roundedMask.frame = bounds
        roundedMask.path = UIBezierPath(
            roundedRect: imageRect,
            cornerRadius: AppRadius.card
        ).cgPath

        layer.mask = roundedMask
    }
}
