//
// Created by Adam Borek on 24.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import Action

protocol ImageHaving {
    var image: Observable<UIImage> { get }
}

protocol AvatarViewModeling {
    var errorMessage: Driver<String> { get }
    var image: Driver<UIImage> { get }

}

final class AvatarViewModel: AvatarViewModeling {
    private enum Strings {
        static let notAuthorizedErrorMessage = "I don't have permission to read your photos ;("
        static let imageNotFoundMessage = "I didn't find the proper image"
    }
    let imageReceiver: ImageHaving

    init(imageReceiver: ImageHaving) {
        self.imageReceiver = imageReceiver
    }

    lazy var imageRetrievingAction: Action<Void, UIImage> = {
        return Action(workFactory: { [weak self] in
            guard let `self` = self else { return .empty() }
            return self.imageReceiver.image
        })
    }()

    var image: Driver<UIImage> {
        return imageRetrievingAction.elements
            .asDriver(onErrorDriveWith: .never())
    }

    var errorMessage: Driver<String> {
        return imageRetrievingAction.errors
            .map { actionError -> String? in
                guard case let .underlyingError(error) = actionError else { return nil }
                switch error {
                case GalleryReadingErrors.notAuthorized:
                    return Strings.notAuthorizedErrorMessage
                case GalleryReadingErrors.imageNotFound:
                    return Strings.imageNotFoundMessage
                default:
                    return nil
                }
            }.unwrap()
            .asDriver(onErrorDriveWith: .never())
    }
}
