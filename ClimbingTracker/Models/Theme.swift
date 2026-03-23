//
//  Theme.swift
//  ClimbingTracker
//
//  统一的主题色和设计系统
//

import SwiftUI

struct Theme {
    // MARK: - 主题色

    /// 主色调（深青色）
    static let primary = Color(red: 0.12, green: 0.48, blue: 0.55)

    /// 主色调柔和版（浅青色）
    static let primarySoft = Color(red: 0.85, green: 0.94, blue: 0.96)

    // MARK: - 间距系统

    /// 小间距 (8pt)
    static let spacingSmall: CGFloat = 8

    /// 中等间距 (12pt)
    static let spacingMedium: CGFloat = 12

    /// 大间距 (16pt)
    static let spacingLarge: CGFloat = 16

    // MARK: - 圆角

    /// 小圆角 (8pt)
    static let cornerRadiusSmall: CGFloat = 8

    /// 中等圆角 (10pt)
    static let cornerRadiusMedium: CGFloat = 10

    /// 大圆角 (14pt)
    static let cornerRadiusLarge: CGFloat = 14

    // MARK: - 字体大小

    /// 小字体 (11pt)
    static let fontSizeSmall: CGFloat = 11

    /// 中等字体 (14pt)
    static let fontSizeMedium: CGFloat = 14

    /// 大字体 (16pt)
    static let fontSizeLarge: CGFloat = 16
}
