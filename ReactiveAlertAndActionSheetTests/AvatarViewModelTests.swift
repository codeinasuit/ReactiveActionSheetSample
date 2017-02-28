//
// Created by Adam Borek on 24.01.2017.
// Copyright (c) 2017 Adam Borek. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import RxBlocking
import RxCocoa
import RxSwiftExt
import NSObject_Rx
import Action

@testable import ReactiveAlertAndActionSheet

final class AvatarViewModelTests: XCTestCase {
    private var subject: AvatarViewModel!
    var imageHavingMock: ImageHavingStub!
    var testScheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        rx_disposeBag = DisposeBag()
        imageHavingMock = ImageHavingStub()
        subject = AvatarViewModel(imageReceiver: imageHavingMock)
    }
    
    override func tearDown() {
        super.tearDown()
        testScheduler = nil
        subject = nil
    }
    
    func simulateTaps(at times: Int...) {
        let events: [Recorded<Event<Void>>] = times.map { next($0, ()) }
        let taps = testScheduler.createHotObservable(events)
        taps.bindTo(subject.chooseImageButtonPressed)
            .disposed(by: rx_disposeBag)
    }
    
    func test_receiveImage_onButtonClick() {
        let buttonTap = PublishSubject<Void>()
        buttonTap.bindTo(subject.chooseImageButtonPressed)
            .disposed(by: rx_disposeBag)
        
        var resultImage: UIImage!
        subject.image.drive(onNext: { image in
            resultImage = image
        }).disposed(by: rx_disposeBag)
        
        buttonTap.onNext(())
        
        XCTAssertEqual(resultImage, imageHavingMock.expectedImage)
    }
    
    func test_receiveImage_onButtonClick_version2() {
        imageHavingMock.expectedImage = UIImage()
        simulateTaps(at: 100, 200)
        
        let observer = testScheduler.createObserver(UIImage.self)
        subject.image.drive(observer)
            .disposed(by: rx_disposeBag)
        testScheduler.start()
        
        let expectedEvents = [
            next(100, imageHavingMock.expectedImage),
            next(200, imageHavingMock.expectedImage)
        ]
        XCTAssertEqual(observer.events, expectedEvents)
    }
    
    func test_whenActionReturnsNotAuthorizedError_displayProperMessage() {
        imageHavingMock.givenError = GalleryReadingErrors.notAuthorized
        simulateTaps(at: 100)
        let observer = testScheduler.createObserver(String.self)
        
        subject.errorMessage.drive(observer)
            .disposed(by: rx_disposeBag)
        testScheduler.start()
        
        XCTAssertEqual(observer.events, [next(100, "I don't have permission to read your photos ;(")])
    }
    
    func test_whenThereAreAnyOfImageInsideGalery_displayProperMessage() {
        simulateTaps(at: 100)
        imageHavingMock.givenError = GalleryReadingErrors.imageNotFound
        let observer = testScheduler.createObserver(String.self)
        
        subject.errorMessage.drive(observer)
            .disposed(by: rx_disposeBag)
        testScheduler.start()
        
        XCTAssertEqual(observer.events, [next(100, "I didn't find the proper image")])
    }
    
    func test_asksOnlyOnceForImage_perButtonTap() {
        simulateTaps(at: 100)
        let imageObserver = testScheduler.createObserver(UIImage.self)
        subject.image.drive(imageObserver)
            .disposed(by: rx_disposeBag)
        let errorMessageObserver = testScheduler.createObserver(String.self)
        subject.errorMessage.drive(errorMessageObserver)
            .disposed(by: rx_disposeBag)
        
        testScheduler.start()
        XCTAssertEqual(imageHavingMock.invocationCount, 1)
    }
}

final class ImageHavingStub: ImageHaving {
    var expectedImage = UIImage()
    var givenError: Error? = nil
    var invocationCount = 0

    var image: Observable<UIImage> {
        invocationCount += 1
        if let error = givenError {
            return .error(error)
        }
        return .just(expectedImage)
    }
}
