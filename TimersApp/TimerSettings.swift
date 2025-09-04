// מחלקה גלובלית לניהול זמן ההתחלה לבחור הטיימר.
import Foundation
import Combine
import SwiftUI

class TimerSettings: ObservableObject {
    @Published var initialTime: Int = 5 * 60 // ברירת מחדל 5 דקות
    @Published var autoStart: Bool = false
}
