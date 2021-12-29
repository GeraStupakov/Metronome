//
//  ThemeApp.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/30/21.
//

import UIKit

enum ThemeApp: Int, CaseIterable {
    case light = 0
    case dark
}

extension ThemeApp {
    
    @Persist(key: "app_theme", defaultValue: ThemeApp.light.rawValue)
    private static var appTheme: Int
    
    // Сохранение темы в UserDefaults
    func save() {
        ThemeApp.appTheme = self.rawValue
    }
    
    // Текущая тема приложения
    static var current: ThemeApp {
        ThemeApp(rawValue: appTheme) ?? .light
    }
    
    @available(iOS 13.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    func setActive() {
        // Сохраняем активную тему
        save()
        
        guard #available(iOS 13.0, *) else { return }
        // Устанавливаем активную тему для всех окон приложения
        UIApplication.shared.windows
            .forEach { $0.overrideUserInterfaceStyle = userInterfaceStyle }
    }
    
}

extension UIWindow {
    func initTheme() {
        guard #available(iOS 13.0, *) else { return }
        overrideUserInterfaceStyle = ThemeApp.current.userInterfaceStyle
    }
}
