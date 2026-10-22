import Foundation

public extension Date {
    /// Formats a date range: "12 Oct – 16 Oct 2026"
    func formattedRange(to endDate: Date) -> String {
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: self)
        let endYear = calendar.component(.year, from: endDate)
        
        let startFormatter = DateFormatter()
        startFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let endFormatter = DateFormatter()
        endFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if startYear == endYear {
            startFormatter.dateFormat = "d MMM"
            endFormatter.dateFormat = "d MMM yyyy"
        } else {
            startFormatter.dateFormat = "d MMM yyyy"
            endFormatter.dateFormat = "d MMM yyyy"
        }
        
        let startString = startFormatter.string(from: self)
        let endString = endFormatter.string(from: endDate)
        
        if calendar.isDate(self, inSameDayAs: endDate) {
            return endString
        }
        return "\(startString) – \(endString)"
    }

    /// Example: "Thursday, Oct 15, 2026"
    var journalDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: self)
    }

    /// Example: "OCT 15"
    var shortMonthDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self).uppercased()
    }

    /// Example: "15 OCT 2026"
    var stampDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self).uppercased()
    }

    /// Relative or friendly display: "Today", "Yesterday", or "Oct 15"
    var relativeDayString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return shortMonthDay
        }
    }
}
