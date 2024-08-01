//
//  AddingCalendarEventView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 31/07/2024.
//

import SwiftUI
import EventKit

struct AddingCalendarEventView: View {
    var dataElement: QueueItem
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var benefitName: String
    @State var pickedHour: Date = .now
    @State var selectedStartTime: String = "6:00"
    @State var durationTime = 15
    @State var pickedDate: Date
    @State private var selectedIndex: Int? = 1
    @State private var notes: String = ""
    @State private var shouldShowAlert: Bool = false
    @FocusState private var textFieldFocused
    
    
    init(dataElement: QueueItem, calendarManager: AppCalendarEventManager) {
        self.dataElement = dataElement
        _viewModel = StateObject(wrappedValue: ViewModel(calendarManager: calendarManager))
        benefitName = dataElement.queueResult.attributes.benefit ?? ""
        pickedDate = dataElement.queueResult.attributes.dates?.date?.convertToDate() ?? .now
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Dodaj wizytę")
                    .font(.title3.bold())
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle.fill")
                }
                .foregroundStyle(.primary)
                .accessibilityLabel("Zamknij widok")
                .accessibilityAddTraits(.isButton)
            }
            .padding()
            .background(.primary.opacity(0.15))
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    Group {
                        HStack {
                            Text("Gdzie?")
                                .font(.headline).bold()
                            Spacer()
                        }
                        .padding([.top, .leading, .trailing])
                        
                        TextField("Benefit", text: $benefitName, axis: .vertical)
                            .padding([.leading, .trailing])
                            .focused($textFieldFocused)
                    }
                    .accessibilityElement(children: .combine)
                    
                    Divider()
                        .padding([.leading, .trailing])
                    
                    HStack {
                        Text("Kiedy?")
                            .font(.headline).bold()
                        Spacer()
                    }
                    .padding()
                    
                    CustomHourPicker(selectedIndex: $selectedIndex, selectedDuration: $durationTime, selectedStartTime: $selectedStartTime)
                    
                    DatePicker("Data", selection: $pickedDate, displayedComponents: .date)
                        .labelsHidden()
                    
                    Picker("Jak długo?", selection: $durationTime) {
                        ForEach([1] + Array(stride(from: 15, to: 61, by: 15)), id: \.self) {
                            if $0 < 60 {
                                if durationTime == $0 {
                                    Text("\($0)min")
                                } else {
                                    Text("\($0)")
                                }
                            } else {
                                Text("\($0 / 60) h")
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .accessibilityLabel("Długość wizyty")
                    
                    HStack {
                        Text("Dodatkowe informacje")
                            .font(.headline).bold()
                        Spacer()
                    }
                    .padding()
                    
                    TextField(text: $notes, axis: .vertical) {
                        Text("Tutaj możesz dodać swoje notatki")
                    }
                    .padding([.leading, .trailing])
                    .focused($textFieldFocused)
                    
                    Divider()
                        .padding([.leading, .trailing])
                }
                
                if !textFieldFocused {
                    Button {
                        viewModel.createCalendarEvent(dataElement: dataElement, notes: notes, pickedDate: pickedDate, durationTime: durationTime, pickedHour: selectedStartTime)
                        dismiss()
                    } label: {
                        Text("Dodaj wizytę").bold()
                            .modifier(CustomButton(isCancel: false, shouldBeTransparent: false))
                    }
                    .foregroundStyle(.primary)
                    .frame(maxWidth: 300)
                }
            }
        }
        .onChange(of: viewModel.calendarError, { oldValue, newValue in
            if viewModel.calendarError != nil {
                shouldShowAlert.toggle()
            }
        })
        .alert("Wystąpił błąd podczas zapisywania wydarzenia", isPresented: $shouldShowAlert) {
            Button("Ok", role: .cancel) { dismiss() }
        }
        .onTapGesture {
            textFieldFocused = false
        }
    }
}

#Preview {
    AddingCalendarEventView(dataElement: .defaultElement, calendarManager: AppCalendarEventManager(eventStore: EKEventStore()))
}
