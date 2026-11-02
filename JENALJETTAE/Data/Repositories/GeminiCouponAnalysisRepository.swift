//
//  GeminiCouponAnalysisRepository.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/30/26.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseAppCheck

// MARK: - Coupon Analysis Error | 인증 및 이미지 분석 실패 안내
enum CouponAnalysisError: LocalizedError {
    case invalidImage
    case imageTooLarge
    case unauthorized
    case authenticationFailed
    case rateLimited
    case serverUnavailable
    case invalidResponse
    case connectionFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            "이미지를 처리할 수 없어요. 다른 사진을 선택해주세요."
        case .imageTooLarge:
            "이미지 크기가 너무 커요. 다른 사진으로 다시 시도해주세요."
        case .unauthorized:
            "앱 인증에 실패했어요. 앱을 다시 실행하고 시도해주세요."
        case .authenticationFailed:
            "Firebase 인증에 실패했어요. 네트워크 연결을 확인해주세요."
        case .rateLimited:
            "무료 AI 분석 한도에 도달했어요. 잠시 후 다시 시도해주세요."
        case .serverUnavailable:
            "분석 서버에 문제가 발생했어요. 잠시 후 다시 시도해주세요."
        case .invalidResponse:
            "쿠폰 분석 결과를 읽을 수 없어요. 다시 시도해주세요."
        case .connectionFailed:
            "인터넷 연결을 확인하고 다시 시도해주세요."
        }
    }
}

// MARK: - Gemini Coupon Analysis Repository | 이미지 전처리와 Worker 통신 담당
struct GeminiCouponAnalysisRepository: CouponAnalysisRepository {
    private let endpoint = URL(string: "https://jenaljettae-api.geunhojeong-jgh.workers.dev/analyze")!

    func analyze(imageData: Data) async throws -> CouponDraft {
        guard !imageData.isEmpty else { throw CouponAnalysisError.invalidImage }

        // MARK: - Image Preparation | 원본 이미지를 JPEG로 변환하고 Base64 인코딩
        let jpegData = try await prepareJPEG(from: imageData)
        let base64Image = jpegData.base64EncodedString()
        guard base64Image.count <= 8_000_000 else { throw CouponAnalysisError.imageTooLarge }

        // MARK: - Firebase Auth | 익명 사용자 인증 및 ID Token 발급
        let authToken: String

        do {
            let user = try await getOrCreateUser()
            authToken = try await user.getIDToken()

            #if DEBUG
            print("FIREBASE_AUTH - ID Token 발급 성공")
            #endif
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            #if DEBUG
            let authError = error as NSError
            print("FIREBASE_AUTH - 인증 실패: \(authError.domain), \(authError.code), \(authError.localizedDescription)")
            #endif

            throw CouponAnalysisError.authenticationFailed
        }

        // MARK: - Firebase App Check | 앱 인증 토큰 발급
        let appCheckToken: String

        do {
            appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false).token

            #if DEBUG
            print("APP_CHECK - 토큰 발급 성공")
            #endif
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            #if DEBUG
            let appCheckError = error as NSError
            print("APP_CHECK - 토큰 발급 실패: \(appCheckError.domain), \(appCheckError.code), \(appCheckError.localizedDescription)")
            #endif

            throw CouponAnalysisError.authenticationFailed
        }

        // MARK: - Request | Firebase 인증 헤더와 JPEG 이미지 전송
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue(appCheckToken, forHTTPHeaderField: "X-Firebase-AppCheck")
        request.httpBody = try JSONEncoder().encode(
            AnalyzeRequest(imageBase64: base64Image, mimeType: "image/jpeg")
        )

        // MARK: - Network | Cloudflare Worker 응답 수신
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            #if DEBUG
            print("GEMINI - 네트워크 오류: \(error.localizedDescription)")
            #endif

            throw CouponAnalysisError.connectionFailed
        }

        // MARK: - HTTP Status | 인증 및 서버 오류 구분
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CouponAnalysisError.invalidResponse
        }

        // MARK: - Debug Log | Worker 응답 및 간헐적인 Gemini 오류 추적
        #if DEBUG
        print("GEMINI - Worker 응답 코드: \(httpResponse.statusCode)")

        if !(200...299).contains(httpResponse.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? "응답 본문 없음"
            print("GEMINI - Worker 오류 상세: \(errorBody)")
        }
        #endif

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            throw CouponAnalysisError.invalidImage
        case 413:
            throw CouponAnalysisError.imageTooLarge
        case 401:
            throw CouponAnalysisError.unauthorized
        case 429:
            throw CouponAnalysisError.rateLimited
        default:
            throw CouponAnalysisError.serverUnavailable
        }

        // MARK: - Response Mapping | Worker 응답을 쿠폰 초안으로 변환
        guard let result = try? JSONDecoder().decode(AnalyzeResponse.self, from: data) else {
            throw CouponAnalysisError.invalidResponse
        }

        var draft = CouponDraft()
        draft.title = clean(result.title)
        draft.brand = clean(result.brand)
        draft.couponNumber = clean(result.couponNumber)?.filter { !$0.isWhitespace }
        draft.reviewNotes = result.needsReview ?? []

        // MARK: - Expiry Date | YYYY-MM-DD 문자열을 날짜로 변환
        if let expiryText = clean(result.expiryDate) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.isLenient = false

            if let date = formatter.date(from: expiryText),
               formatter.string(from: date) == expiryText {
                draft.expiryDate = Calendar.current.startOfDay(for: date)
            } else {
                draft.reviewNotes.append("만료일 형식을 확인해주세요.")
            }
        }

        if draft.title == nil { draft.reviewNotes.append("상품명을 직접 확인해주세요.") }
        if draft.expiryDate == nil { draft.reviewNotes.append("만료일을 직접 확인해주세요.") }

        // MARK: - Analysis Result | 서버에서 받은 쿠폰 초안 반환
        return draft
    }

    // MARK: - Prepare JPEG | HEIC 등 이미지를 JPEG로 변환 및 축소
    @MainActor
    private func prepareJPEG(from data: Data) throws -> Data {
        guard let image = UIImage(data: data) else {
            throw CouponAnalysisError.invalidImage
        }

        let maxDimension: CGFloat = 2400
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: size)
        let processed = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

        guard let jpeg = processed.jpegData(compressionQuality: 0.80) else {
            throw CouponAnalysisError.invalidImage
        }

        return jpeg
    }

    // MARK: - Anonymous User | 기존 사용자 재사용 또는 익명 로그인
    private func getOrCreateUser() async throws -> User {
        if let user = Auth.auth().currentUser { return user }
        return try await Auth.auth().signInAnonymously().user
    }

    // MARK: - Clean Text | 빈 문자열을 nil로 정리
    private func clean(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else { return nil }
        return value
    }
}

// MARK: - Analyze Request | Worker 요청 JSON
private struct AnalyzeRequest: Encodable {
    let imageBase64: String
    let mimeType: String
}

// MARK: - Analyze Response | Worker 분석 응답 JSON
private struct AnalyzeResponse: Decodable {
    let title: String?
    let brand: String?
    let expiryDate: String?
    let couponNumber: String?
    let needsReview: [String]?
}
