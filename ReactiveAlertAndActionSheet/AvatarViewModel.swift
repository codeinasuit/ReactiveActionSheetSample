//
// Created by Adam Borek on 24.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import Action

protocol AvatarViewModeling {
    //Input
    var chooseImageButtonPressed: AnyObserver<Void> { get }
    
    //Output
    var errorMessage: Driver<String> { get }
    var image: Driver<UIImage> { get }
}

final class AvatarViewModel: AvatarViewModeling {
    fileprivate enum Strings {
        static let notAuthorizedErrorMessage = "I don't have permission to read your photos ;("
        static let imageNotFoundMessage = "I didn't find the proper image"
    }
    
    fileprivate let _chooseImageButtonPressed = PublishSubject<Void>()
    
    let image: Driver<UIImage>
    let errorMessage: Driver<String>
    
    init(imageReceiver: ImageHaving) {
        let imageResult = _chooseImageButtonPressed.asObservable()
            .flatMap { imageReceiver.image.materialize() }
            .share()
        
        image = imageResult
            .elements()
            .asDriver(onErrorDriveWith: .never())
        
        errorMessage = imageResult
            .errors()
            .map(mapErrorMessages)
            .unwrap()
            .asDriver(onErrorDriveWith: .never())
    }
}

fileprivate func mapErrorMessages(error: Error) -> String? {
    switch error {
    case GalleryReadingErrors.notAuthorized:
        return AvatarViewModel.Strings.notAuthorizedErrorMessage
    case GalleryReadingErrors.imageNotFound:
        return AvatarViewModel.Strings.imageNotFoundMessage
    default:
        return nil
    }
}

extension AvatarViewModel {
    var chooseImageButtonPressed: AnyObserver<Void> {
        return _chooseImageButtonPressed.asObserver()
    }
}
