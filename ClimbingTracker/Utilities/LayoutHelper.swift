//
//  LayoutHelper.swift
//  ClimbingTracker
//
//  动态布局计算工具
//

import UIKit

struct LayoutHelper {
    // MARK: - 屏幕尺寸

    /// 获取屏幕宽度
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    /// 获取屏幕高度
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    // MARK: - 日历布局

    /// 日历水平边距（更接近系统日历的布局）
    static let calendarHorizontalPadding: CGFloat = 12

    /// 日历单元格高度（基于屏幕宽度动态计算）
    static var calendarCellHeight: CGFloat {
        let availableWidth = screenWidth - (calendarHorizontalPadding * 2)
        let cellWidth = availableWidth / 7
        return cellWidth * 0.9 // 高度略小于宽度，保持美观比例
    }

    // MARK: - 图表布局

    /// 图表高度（基于屏幕宽度动态计算）
    static var chartHeight: CGFloat {
        max(200, screenWidth * 0.5) // 最小200，或屏幕宽度的50%
    }
}
