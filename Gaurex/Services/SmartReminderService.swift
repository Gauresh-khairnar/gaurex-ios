//
//  SmartReminderService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI
import UserNotifications

public final class SmartReminderService: ObservableObject {
    public static let shared = SmartReminderService()
    
    @Published public var reminders: [SmartReminder] = []
    @Published public var hasNotificationPermission: Bool = false
    
    private let storageKey = "gaurex_smart_reminders"
    
    private init() {
        loadReminders()
        checkPermission()
    }
    
    public func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.hasNotificationPermission = granted
            }
        }
    }
    
    public func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasNotificationPermission = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    public func addReminder(_ reminder: SmartReminder) {
        reminders.insert(reminder, at: 0)
        persist()
        
        // Schedule iOS local notification if permitted
        if hasNotificationPermission {
            let content = UNMutableNotificationContent()
            content.title = "GAUREX: \(reminder.title)"
            content.body = reminder.message
            content.sound = .default
            
            let triggerDate = reminder.triggerDate
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    public func snoozeReminder(id: String, minutes: Int = 60) {
        if let idx = reminders.firstIndex(where: { $0.id == id }) {
            reminders[idx].isSnoozed = true
            reminders[idx].triggerDate = Calendar.current.date(byAdding: .minute, value: minutes, to: Date()) ?? Date()
            persist()
        }
    }
    
    public func markCompleted(id: String) {
        if let idx = reminders.firstIndex(where: { $0.id == id }) {
            reminders[idx].isCompleted = true
            persist()
        }
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([SmartReminder].self, from: data) {
            self.reminders = saved
        }
    }
}
