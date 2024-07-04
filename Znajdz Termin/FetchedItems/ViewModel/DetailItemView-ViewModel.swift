//
//  DetailItemView-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 04/07/2024.
//

import Foundation

extension DetailItemView {
    class ViewModel: ObservableObject {
        func checkIfShouldShowFacilities(attributes: Attributes) -> Bool {
            attributes.benefitsForChildren == "Y" || attributes.toilet == "Y" || attributes.ramp == "Y" || attributes.carPark == "Y" || attributes.elevator == "Y"
        }
        
        func removeNumberFromBrackets(number: String) -> String {
            if let numberInBracketRange = number.range(of: ")")?.lowerBound, let restOfNumberRange = number.range(of: ")")?.upperBound {
                print(number.prefix(upTo: numberInBracketRange))
                var numberToReturn = number.prefix(upTo: numberInBracketRange).trimmingCharacters(in: .whitespaces)
                numberToReturn = numberToReturn.replacingOccurrences(of: "(", with: "")
                numberToReturn = numberToReturn.replacingOccurrences(of: "0", with: "")
                print(numberToReturn)
                
                let goodNumber = number.suffix(from: restOfNumberRange)
                print("Good number ", goodNumber)
                
                return "+48 " + numberToReturn + " " + goodNumber
            }
            
            return number
        }
        
        func extractNumberWithInternalNumber(number: String) -> (number: String, insideNumber: String?) {
            let uppercasedNumber = number.uppercased()
            
            if let indexForPhoneNumber = uppercasedNumber.range(of: "WEW")?.lowerBound, let indexForInternalNumber = uppercasedNumber.range(of: "WEW")?.upperBound {
                let numberWithoutInsideNumber = uppercasedNumber.prefix(upTo: indexForPhoneNumber).trimmingCharacters(in: .whitespaces)
                let insideNumber = uppercasedNumber.suffix(from: indexForInternalNumber).trimmingCharacters(in: CharacterSet([".", ".", "-", " "]))
                
                return (String(numberWithoutInsideNumber), String(insideNumber))
            }
            
            return (number, nil)
        }
        
        func checkIfThereAreTwoNumbers(number: String) -> [String] {
            let splittedNumber = number.split(separator: ";")
            
            if splittedNumber.count == 2 {
                let firstNumber = String(splittedNumber[0])
                let secondNumber = String(splittedNumber[1])
                return [firstNumber, secondNumber]
            }
            
            return [number]
        }
        
        func createURLFromPhoneNumber(number: String, internalNumber: String? = nil) -> URL? {
            if let internalNumber {
                if let phoneURL = URL(string: "tel:\(number),\(internalNumber)") {
                    return phoneURL
                }
            } else {
                if let phoneURL = URL(string: "tel:\(number)") {
                    return phoneURL
                }
            }
            
            return nil
        }
        
        func preparePhoneNumberToDisplay(phoneNumber: String?) -> [PhoneNumber] {
            guard let phoneNumber else { return [] }
            
            let checkedForMultipleNumbers = checkIfThereAreTwoNumbers(number: phoneNumber)
            var arrayOfNumbers: [PhoneNumber] = []
            
            checkedForMultipleNumbers.forEach {
                var touplePhoneNumber: (String, String?) = ($0, nil)
                touplePhoneNumber.0 = removeNumberFromBrackets(number: $0)
                touplePhoneNumber = extractNumberWithInternalNumber(number: touplePhoneNumber.0)
                
                if let url = createURLFromPhoneNumber(number: touplePhoneNumber.0, internalNumber: touplePhoneNumber.1) {
                    arrayOfNumbers.append(PhoneNumber(phoneNumber: touplePhoneNumber.0, urlPhoneNumber: url))
                }
            }
            
            return arrayOfNumbers
        }
    }
}
