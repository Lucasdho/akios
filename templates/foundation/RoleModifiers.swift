// RoleModifiers.swift — starter scaffold, copied by /akios:init into Foundation/Design-tokens/.
//
// The closed `.textStyle` / `.imageStyle` role-modifier vocabulary. Shape defined by
// `swift-dev`'s `swiftui-design-system` guide
// (skills/swift-dev/skills/swiftui-design-system/GUIDE.md, ui-overhaul-implementation.md Phase
// 4.1) and `swiftui-design-doctrine.md` §4 (B4). A genuinely one-off treatment adds a role here
// — never a freeform `.font(size:weight:)` at the call site.
//
// Rule: a role modifier reads static DesignSystem tokens only — it stays dumb-component-pure
// (no @Environment, no service lookups).

import SwiftUI

enum TextStyle {
    case hero
    case body
    // More roles (.statValue, .sectionLabel, .caption) as the app's screens need them.
}

enum ImageStyle {
    case avatar
    // More roles (.thumbnail, .badge, .hero) as the app's screens need them.
}

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        switch style {
        case .hero:
            return self.font(DesignSystem.Typography.hero)
        case .body:
            return self.font(DesignSystem.Typography.body)
        }
    }
}

extension Image {
    func imageStyle(_ style: ImageStyle) -> some View {
        switch style {
        case .avatar:
            return self
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
        }
    }
}
