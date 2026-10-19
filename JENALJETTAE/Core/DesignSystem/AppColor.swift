//
//  AppColor.swift
//  JENALJETTAE
//
//  Created by 정근호 on 10/12/26.
//

import SwiftUI
import UIKit

enum AppColor {

    // MARK: - Primary

    // 주요 버튼, 선택 상태
    static let primary = adaptive(light: #colorLiteral(red: 0.470588, green: 0.152941, blue: 0.235294, alpha: 1), dark: #colorLiteral(red: 0.580392, green: 0.2, blue: 0.309804, alpha: 1)) // #78273C / #94334F

    // 버튼 누름 상태
    static let primaryPressed = adaptive(light: #colorLiteral(red: 0.360784, green: 0.113725, blue: 0.176471, alpha: 1), dark: #colorLiteral(red: 0.470588, green: 0.152941, blue: 0.235294, alpha: 1)) // #5C1D2D / #78273C

    // 주요 버튼 위의 텍스트
    static let onPrimary = adaptive(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) // #FFFFFF / #FFFFFF

    // 강조 텍스트, 아이콘
    static let primaryForeground = adaptive(light: #colorLiteral(red: 0.470588, green: 0.152941, blue: 0.235294, alpha: 1), dark: #colorLiteral(red: 0.941176, green: 0.709804, blue: 0.784314, alpha: 1)) // #78273C / #F0B5C8

    // 약한 강조 배경
    static let primaryTint = adaptive(light: #colorLiteral(red: 0.964706, green: 0.92549, blue: 0.937255, alpha: 1), dark: #colorLiteral(red: 0.223529, green: 0.141176, blue: 0.176471, alpha: 1)) // #F6ECEF / #39242D
    
    // 보조 버튼 눌림 배경색
    static let secondaryPressed = adaptive(light: #colorLiteral(red: 0.968627, green: 0.960784, blue: 0.964706, alpha: 1), dark: #colorLiteral(red: 0.219608, green: 0.188235, blue: 0.211765, alpha: 1))


    // MARK: - Background & Surface

    // 전체 화면 배경
    static let background = adaptive(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 0.078431, green: 0.070588, blue: 0.078431, alpha: 1)) // #FFFFFF / #141214

    // 카드 배경
    static let card = adaptive(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 0.12549, green: 0.105882, blue: 0.117647, alpha: 1)) // #FFFFFF / #201B1E

    // 정보 영역 배경
    static let surface = adaptive(light: #colorLiteral(red: 0.968627, green: 0.960784, blue: 0.964706, alpha: 1), dark: #colorLiteral(red: 0.12549, green: 0.105882, blue: 0.117647, alpha: 1)) // #F7F5F6 / #201B1E

    // 입력창 배경
    static let inputSurface = adaptive(light: #colorLiteral(red: 0.968627, green: 0.960784, blue: 0.964706, alpha: 1), dark: #colorLiteral(red: 0.129412, green: 0.113725, blue: 0.12549, alpha: 1)) // #F7F5F6 / #211D20

    // 테두리, 구분선
    static let border = adaptive(light: #colorLiteral(red: 0.901961, green: 0.878431, blue: 0.890196, alpha: 1), dark: #colorLiteral(red: 0.309804, green: 0.231373, blue: 0.266667, alpha: 1)) // #E6E0E3 / #4F3B44


    // MARK: - Text

    // 제목, 본문
    static let textPrimary = adaptive(light: #colorLiteral(red: 0.090196, green: 0.078431, blue: 0.090196, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) // #171417 / #FFFFFF

    // 부가 설명, 날짜
    static let textSecondary = adaptive(light: #colorLiteral(red: 0.419608, green: 0.384314, blue: 0.407843, alpha: 1), dark: #colorLiteral(red: 0.764706, green: 0.717647, blue: 0.74902, alpha: 1)) // #6B6268 / #C3B7BF


    // MARK: - Disabled

    // 비활성화 배경
    static let disabledSurface = adaptive(light: #colorLiteral(red: 0.901961, green: 0.878431, blue: 0.890196, alpha: 1), dark: #colorLiteral(red: 0.219608, green: 0.188235, blue: 0.211765, alpha: 1)) // #E6E0E3 / #383036

    // 비활성화 텍스트
    static let disabledText = adaptive(light: #colorLiteral(red: 0.462745, green: 0.419608, blue: 0.447059, alpha: 1), dark: #colorLiteral(red: 0.694118, green: 0.631373, blue: 0.670588, alpha: 1)) // #766B72 / #B1A1AB


    // MARK: - Black Surface

    // 블랙 강조 카드
    static let blackSurface = adaptive(light: #colorLiteral(red: 0.090196, green: 0.078431, blue: 0.090196, alpha: 1), dark: #colorLiteral(red: 0.047059, green: 0.039216, blue: 0.047059, alpha: 1)) // #171417 / #0C0A0C
    
    static let destructiveBackground = adaptive(light: #colorLiteral(red: 0.090196, green: 0.078431, blue: 0.090196, alpha: 1), dark: #colorLiteral(red: 0.407843, green: 0.388235, blue: 0.407843, alpha: 1))

    // 블랙 배경 위 강조 텍스트
    static let onBlackAccent = adaptive(light: #colorLiteral(red: 0.941176, green: 0.709804, blue: 0.784314, alpha: 1), dark: #colorLiteral(red: 0.941176, green: 0.709804, blue: 0.784314, alpha: 1)) // #F0B5C8 / #F0B5C8

    // 블랙 배경 위 보조 텍스트
    static let onBlackSecondary = adaptive(light: #colorLiteral(red: 0.827451, green: 0.784314, blue: 0.807843, alpha: 1), dark: #colorLiteral(red: 0.827451, green: 0.784314, blue: 0.807843, alpha: 1)) // #D3C8CE / #D3C8CE


    // MARK: - Adaptive Color

    // 라이트·다크 모드에 따라 색상 선택
    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
