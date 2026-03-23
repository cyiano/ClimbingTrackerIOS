//
//  ViewModifiers.swift
//  ClimbingTracker
//
//  统一的视图样式修饰器
//

import SwiftUI

// MARK: - 卡片样式

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground).opacity(0.95))
            .cornerRadius(Theme.cornerRadiusLarge)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

// MARK: - 渐变背景样式

struct GradientBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.93, green: 0.98, blue: 0.99),
                        Color(red: 0.97, green: 0.97, blue: 0.98)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .ignoresSafeArea()
            )
    }
}

// MARK: - View扩展

extension View {
    /// 应用卡片样式
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    /// 应用渐变背景
    func gradientBackground() -> some View {
        modifier(GradientBackgroundStyle())
    }
}
