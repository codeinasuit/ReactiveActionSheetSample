//
// Created by Adam Borek on 24.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import RxSwiftExt
import Action

@testable import ReactiveAlertAndActionSheet

final class ViewModelTests: XCTestCase {
    private var subject: AvatarViewModel!
    var imageHavingMock: ImageHavingMock!
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        imageHavingMock = ImageHavingMock()
        subject = AvatarViewModel(imageReceiver: imageHavingMock)
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        subject = nil
    }

    func test_actionReturnsImageFromImageReceiver() {
        let expectedImage = UIImage()
        imageHavingMock.expectedImage = expectedImage
        var resultImage: UIImage?
        subject.imageRetrievingAction.elements.subscribe(onNext: {
            resultImage = $0
        }).disposed(by: disposeBag)
        _ = subject.imageRetrievingAction.execute()
        XCTAssertTrue(resultImage === expectedImage)
    }
}

final class ImageHavingMock: ImageHaving {
    var expectedImage: UIImage? = UIImage()

    var image: Observable<UIImage> {
        guard let image = expectedImage else {
            return .empty()
        }
        return .just(image)
    }
}
