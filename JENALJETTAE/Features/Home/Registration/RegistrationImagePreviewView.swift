//
//  RegistrationImagePreviewView.swift
//  JENALJETTAE
//
//  Created by 정근호 on 11/5/26.
//

import SwiftUI
import UIKit

// MARK: - Registration Image Preview | 전체 화면 이미지 확인 및 아래로 드래그해 닫기
struct RegistrationImagePreviewView: View {
    let image: UIImage

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Close Button | 쿠폰과 동일한 상단 44×44 닫기 버튼
            HStack {
                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(AppColor.card, in: Circle())
                        .overlay {
                            Circle().strokeBorder(AppColor.border, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("이미지 닫기")
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.small)
            .padding(.bottom, AppSpacing.large)

            // MARK: - Zoomable Image | 쿠폰과 동일한 확대·축소 및 이미지 라운드
            ZoomableRegistrationImage(image: image, onDismiss: { dismiss() })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.medium)
        }
        .background(AppColor.background.ignoresSafeArea())
    }
}

// MARK: - Zoomable Registration Image | UIScrollView 기반 확대·축소 및 닫기
private struct ZoomableRegistrationImage: UIViewRepresentable {
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

        // MARK: - Image View | 실제 이미지 부분에만 모서리 라운드
        let imageView = RoundedRegistrationImageView(image: image)
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

        // MARK: - Double Tap | 누른 위치 기준 확대·축소
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        // MARK: - Dismiss Pan | 아래 방향 드래그로 닫기
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

        init(onDismiss: @escaping () -> Void) { self.onDismiss = onDismiss }

        // MARK: - Image Zoom | 확대 중에만 이미지 이동 허용
        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            scrollView.panGestureRecognizer.isEnabled = scrollView.zoomScale > scrollView.minimumZoomScale + 0.01
        }

        // MARK: - Double Tap | 2.5배 확대 또는 원본으로 복귀
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

        // MARK: - Dismiss Pan | 아래로 120pt 이상 드래그하면 닫기
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

        // MARK: - Gesture Validation | 원본 크기의 아래 방향 드래그만 허용
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
                  let scrollView = pan.view as? UIScrollView,
                  scrollView.zoomScale <= scrollView.minimumZoomScale + 0.01 else { return false }

            let velocity = pan.velocity(in: scrollView)
            return velocity.y > 0 && velocity.y > abs(velocity.x)
        }

        private func resetPosition(_ scrollView: UIScrollView) {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                scrollView.transform = .identity
            }
        }
    }
}

// MARK: - Rounded Registration Image View | 실제 이미지 영역에만 라운드 적용
private final class RoundedRegistrationImageView: UIImageView {
    private let roundedMask = CAShapeLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image,
              bounds.width > 0, bounds.height > 0,
              image.size.width > 0, image.size.height > 0 else { return }

        let scale = min(bounds.width / image.size.width, bounds.height / image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let imageRect = CGRect(
            x: (bounds.width - width) / 2,
            y: (bounds.height - height) / 2,
            width: width,
            height: height
        )

        roundedMask.frame = bounds
        roundedMask.path = UIBezierPath(roundedRect: imageRect, cornerRadius: AppRadius.card).cgPath
        layer.mask = roundedMask
    }
}
