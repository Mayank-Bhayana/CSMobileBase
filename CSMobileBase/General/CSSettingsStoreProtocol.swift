//
//  CSSettingsStoreProtocol.swift
//  Pods
//
//  Created by Nicholas McDonald on 3/27/17.
//
//

import Foundation
import RxSwift

public protocol CSSettingsStoreProtocol {
    static var instance:CSSettingsStoreProtocol {get}
    
    func read<S:CSSettings>() -> S
    func syncDownSettings<S:CSSettings>(_ completion:((S, Bool) -> Void)?)
    var settingsObservable: BehaviorSubject<CSSettings?> { get }
}
