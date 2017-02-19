//
// Created by Adam Borek on 25.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import Photos

protocol ImageHaving {
    var image: Observable<UIImage> { get }
}

protocol ImageSource: CustomStringConvertible {
    var image: Observable<UIImage> { get }
}

final class ImageSourceChooser: ImageHaving {
    enum Strings {
        static let cancel = "Cancel"
    }

    weak var presenter: ViewControllerPresenting?
    private let sources: [ImageSource]

    init(sources: [ImageSource]) {
        self.sources = sources
    }

    var image: Observable<UIImage> {
        return selectedOption
                .flatMap { $0 }
    }

    private var selectedOption: Observable<Observable<UIImage>> {
        return Observable.create { [weak self] observer in
            guard let `self` = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let actionSheet = self.prepareActionSheet(with: observer)
            self.presenter?.present(actionSheet)

            return Disposables.create {
                actionSheet.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func prepareActionSheet(with actionTapObserver: AnyObserver<Observable<UIImage>>) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        prepareActionSheetActions(with: actionTapObserver)
                .forEach { actionSheet.addAction($0) }
        return actionSheet
    }

    private func prepareActionSheetActions(with tapObserver: AnyObserver<Observable<UIImage>>) -> [UIAlertAction] {
        var actions = createSourcesActions(with: tapObserver)
        let cancel = createCancelAction(with: tapObserver)
        actions.append(cancel)
        return actions
    }

    private func createSourcesActions(with tapObserver: AnyObserver<Observable<UIImage>>) -> [UIAlertAction] {
        return sources.map { source in
            return UIAlertAction(title: source.description, style: .default) { _ in
                tapObserver.onNext(source.image)
                tapObserver.onCompleted()
            }
        }
    }

    private func createCancelAction(with tapObserver: AnyObserver<Observable<UIImage>>) -> UIAlertAction {
        return UIAlertAction(title: Strings.cancel, style: .cancel) { _ in
            tapObserver.onCompleted()
        }
    }
}
