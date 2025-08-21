import SwiftUI

struct DateNavigationView: View {
    @Binding var selectedDate: Date
    let onDateChanged: (Date) -> Void
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Date())
    }
    
    private var isYesterday: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    }
    
    private var isTomorrow: Bool {
        Calendar.current.isDate(selectedDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
    }
    
    private var displayText: String {
        if isToday {
            return "Today"
        } else if isYesterday {
            return "Yesterday"
        } else if isTomorrow {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: selectedDate)
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Previous Day Button
            Button(action: {
                let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                selectedDate = previousDate
                onDateChanged(previousDate)
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            
            // Current Date Display
            VStack(spacing: 4) {
                Text(displayText)
                    .font(.custom("PlayfairDisplay-Regular", size: 24))
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(formatDate(selectedDate))
                    .font(.custom("NotoSans", size: 14))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            
            // Next Day Button
            Button(action: {
                let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                selectedDate = nextDate
                onDateChanged(nextDate)
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    DateNavigationView(selectedDate: .constant(Date())) { _ in }
        .background(Color.black)
} 