import SwiftUI

// MARK: - 按钮变体

/// 按钮视觉风格
enum AppButtonVariant {
    case primary    // 主操作，填充主色
    case secondary  // 次要操作，填充灰底
    case outline    // 描边按钮
    case danger     // 危险操作，红色
    case ghost      // 无背景，纯文字
}

// MARK: - 按钮尺寸

enum AppButtonSize {
    case small   // 高度 32pt
    case medium  // 高度 44pt（默认）
    case large   // 高度 52pt
}

// MARK: - 图标位置

enum AppButtonIconPosition {
    case leading, trailing
}

// MARK: - 统一按钮组件

/// 统一按钮组件 — 支持多种变体、Loading 状态、图标、禁用
struct AppButton: View {

    let title:         String
    var icon:          String?               = nil
    var iconPosition:  AppButtonIconPosition = .leading
    var variant:       AppButtonVariant      = .primary
    var size:          AppButtonSize         = .medium
    var isFullWidth:   Bool                  = false
    var isLoading:     Bool                  = false
    var isDisabled:    Bool                  = false
    let action:        () -> Void

    var body: some View {
        Button(action: action) {
            buttonLabel
        }
        .buttonStyle(AppPressButtonStyle())
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1)
    }

    // MARK: - 内部视图

    private var buttonLabel: some View {
        HStack(spacing: AppSpacing.sm) {
            if iconPosition == .leading {
                leadingIcon
            }

            Text(title)
                .font(size == .small ? AppFont.buttonSmall : AppFont.button)
                .lineLimit(1)

            if iconPosition == .trailing, let name = icon, !isLoading {
                Image(systemName: name)
                    .font(.system(size: iconFontSize, weight: .semibold))
            }
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .frame(height: buttonHeight)
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(borderColor, lineWidth: variant == .outline ? 1.5 : 0)
        )
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(foregroundColor)
                .scaleEffect(size == .small ? 0.65 : 0.75)
        } else if let name = icon {
            Image(systemName: name)
                .font(.system(size: iconFontSize, weight: .semibold))
        }
    }

    // MARK: - 样式计算

    private var buttonHeight: CGFloat {
        switch size {
        case .small:  return 32
        case .medium: return 44
        case .large:  return 52
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small:  return AppSpacing.md
        case .medium: return AppSpacing.lg
        case .large:  return AppSpacing.xl
        }
    }

    private var iconFontSize: CGFloat {
        switch size {
        case .small:  return 13
        case .medium: return 15
        case .large:  return 17
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:   return AppColor.primary
        case .secondary: return AppColor.surface
        case .outline:   return .clear
        case .danger:    return AppColor.error
        case .ghost:     return .clear
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:   return .white
        case .secondary: return AppColor.textPrimary
        case .outline:   return AppColor.primary
        case .danger:    return .white
        case .ghost:     return AppColor.primary
        }
    }

    private var borderColor: Color {
        switch variant {
        case .outline: return AppColor.primary
        case .danger:  return AppColor.error
        default:       return .clear
        }
    }
}

// MARK: - 按压动效 ButtonStyle

private struct AppPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(AppAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - 语义化快捷构造函数

extension AppButton {
    /// 主按钮
    static func primary(
        _ title: String,
        icon: String? = nil,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> AppButton {
        AppButton(title: title, icon: icon, variant: .primary,
                  isFullWidth: isFullWidth, isLoading: isLoading,
                  isDisabled: isDisabled, action: action)
    }

    /// 次要按钮
    static func secondary(
        _ title: String,
        icon: String? = nil,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> AppButton {
        AppButton(title: title, icon: icon, variant: .secondary,
                  isFullWidth: isFullWidth, action: action)
    }

    /// 描边按钮
    static func outline(
        _ title: String,
        icon: String? = nil,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> AppButton {
        AppButton(title: title, icon: icon, variant: .outline,
                  isFullWidth: isFullWidth, action: action)
    }

    /// 危险按钮
    static func danger(
        _ title: String,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) -> AppButton {
        AppButton(title: title, variant: .danger,
                  isFullWidth: isFullWidth, action: action)
    }
}

// MARK: - Preview

#Preview("按钮组件") {
    ScrollView {
        VStack(spacing: AppSpacing.lg) {
            Group {
                AppButton.primary("开始匹配", icon: "sparkles") {}
                AppButton.primary("加载中", isLoading: true) {}
                AppButton.primary("已禁用", isDisabled: true) {}
            }
            Divider()
            Group {
                AppButton.secondary("次要操作", icon: "plus") {}
                AppButton.outline("描边按钮") {}
                AppButton.danger("删除客户") {}
            }
            Divider()
            HStack {
                AppButton(title: "小号", size: .small, action: {})
                AppButton(title: "中号", size: .medium, variant: .outline, action: {})
                AppButton(title: "大号", size: .large, action: {})
            }
        }
        .padding(AppSpacing.base)
    }
}
