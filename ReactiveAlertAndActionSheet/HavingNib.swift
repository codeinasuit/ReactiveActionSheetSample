//
//  HavingNib.swift
//  ReactiveAlertAndActionSheet
//
//  Created by Adam Borek on 23.01.2017.
//  Copyright © 2017 Adam Borek. All rights reserved.
//

import Foundation
import UIKit

protocol HavingNib {
    static var nibName: String { get }
}

extension HavingNib where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }

    static func fromNib(translatesAutoresizingMaskIntoConstraints: Bool = true) -> Self {
        guard let view = (nib.instantiate(withOwner: nil, options: nil).first { $0 is Self }) as? Self else {
            fatalError("\(Self.self) doesn't have a nib with name: \(nibName)")
        }
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        return view
    }
}
