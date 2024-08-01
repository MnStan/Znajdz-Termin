//
//  CustomHourPicker.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 01/08/2024.
//

import SwiftUI

struct CustomHourPicker: View {
    @Binding var selectedIndex: Int?
    @Binding var selectedDuration: Int
    @Binding var selectedStartTime: String
    let hours = Array(6..<22)
    let minutes = [0, 15, 30, 45]
    var items: [String] = []
    
    var itemHeight: CGFloat = 40.0
    var menuHeightMultiplier: CGFloat = 5
    
    init(selectedIndex: Binding<Int?>, selectedDuration: Binding<Int>, selectedStartTime: Binding<String>) {
        _selectedIndex = selectedIndex
        _selectedDuration = selectedDuration
        _selectedStartTime = selectedStartTime
        for hour in hours {
            for minute in minutes {
                let timeString = String(format: "%d:%02d", hour, minute)
                items.append(timeString)
            }
        }
    }
    
    var body: some View {
        let itemsCountAbove = Double(Int((menuHeightMultiplier - 1)/2))
        
        ZStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(0..<items.count, id: \.self) { index in
                        let time = items[index]
                        
                        Text(time)
                            .font(.caption2)
                            .padding()
                            .id(index)
                            .frame(height: itemHeight)
                            .accessibilityHidden(true)
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, itemHeight * itemsCountAbove)
            }
            .scrollPosition(id: $selectedIndex, anchor: .center)
            .frame(height: itemHeight * (itemsCountAbove * 2 + 1))
            .padding(.vertical, (Int(menuHeightMultiplier) % 2 == 0) ? itemHeight * 0.5 : 0)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .onChange(of: selectedIndex) { oldValue, newValue in
                selectedStartTime = items[selectedIndex ?? 0]
            }
            
            Text("\(items[selectedIndex ?? 0])-\(calculateEndTime(startTime: items[selectedIndex ?? 0], duration: selectedDuration) ?? "")")
                .font(.subheadline)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.gray.opacity(1))
                )
                .allowsHitTesting(false)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Wybór czasu")
        .accessibilityValue("Wybrany czas \(items[selectedIndex ?? 0])")
        .accessibilityHint("Przesuń w górę lub w dół, aby zmienić czas")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                incrementTime()
            case .decrement:
                decrementTime()
            @unknown default:
                break
            }
        }
    }
    
    private func incrementTime() {
        if let currentIndex = selectedIndex, currentIndex < items.count - 1 {
            selectedIndex = currentIndex + 1
        }
    }
    
    private func decrementTime() {
        if let currentIndex = selectedIndex, currentIndex > 0 {
            selectedIndex = currentIndex - 1
        }
    }
    
    func calculateEndTime(startTime: String, duration: Int, format: String = "HH:mm") -> String? {
        func timeFromString(_ timeString: String, format: String = "HH:mm") -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.date(from: timeString)
        }
        
        func stringFromTime(_ date: Date, format: String = "HH:mm") -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.string(from: date)
        }
        
        guard let startDate = timeFromString(startTime, format: format) else {
            return nil
        }
        
        let durationInSeconds: TimeInterval = TimeInterval(duration * 60)
        
        let endDate = startDate.addingTimeInterval(durationInSeconds)
        
        return stringFromTime(endDate, format: format)
    }
}

#Preview {
    CustomHourPicker(selectedIndex: .constant(1), selectedDuration: .constant(15), selectedStartTime: .constant("6:00"))
}
