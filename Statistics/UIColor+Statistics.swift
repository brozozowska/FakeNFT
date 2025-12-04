//
//  UIColor+Statistics.swift
//  FakeNFT
//
//  Created by Yanye Velikanova on 12/3/25.
//

import UIKit

extension UIColor {
    /// Фон для экранов статистики
    static var background: UIColor {
        .systemBackground   // можно поменять на нужный цвет из дизайн-системы
    }

    /// Если где-то используешь backgroundGray — тоже сюда:
    static var backgroundGray: UIColor {
        .secondarySystemBackground
    }
}
