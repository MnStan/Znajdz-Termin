# Znajdz Termin
  
  Mobile iOS application created in SwiftUI to search for dates of services provided by entities of the National Health Fund.
  
  In Poland, access to healthcare services under the National Health Fund (NFZ) is often limited due to long queues and a complicated registration system, leading to frustration among patients. This application aims to simplify the process by providing fast and easy access to information about available appointment slots and the locations of medical facilities.
  
  The current healthcare system can be overwhelming for many patients, and waiting for months to see a specialist can lead to worsening health conditions. By using this app, patients can take control of their healthcare journey, ensuring faster access to services without unnecessary delays. I believe technology should work for us, not against us, especially when it comes to our health.

## Table of Contents

  * [Technologies](#technologies)
  * [API](#API)
  * [App presentation](#app-presentation)

## Technologies
  
  - Swift
  - SwiftUI
  - SwiftData
  - MapKit
  - EventKit
  - Combine

## API

I used informations provided by NFZ - [NFZ API](https://api.nfz.gov.pl)

## App presentation

The application allows users to choose a benefit name from the most popular options, their search history, or by entering a specific one. There is also a dropdown menu for selecting a voivodeship if the user wants to choose a different region than the one determined by their location or if the user has not granted permission to access their location. Additionally, the user can provide extra information, such as:

- Urgent mode: if the user has a referral marked as urgent,
- For children: if the user is searching for a medical service for patients under 18 years old.

The application provides suggestions based on the benefit name entered, helping users find relevant services more quickly and efficiently. This smart search feature ensures a smoother and more personalized experience.

<p align="center">
<img src="https://github.com/user-attachments/assets/ab554070-248a-42ed-b638-30d074d42304" width="425"/> <img src="https://github.com/user-attachments/assets/dc1b1c5f-d8ea-4ffb-87fa-d00f0387daf5" width="425"/> 
</p>

Once the search parameters are set, the user is taken to a results screen, as shown in. This view displays a list of healthcare facilities offering the selected service, with key informations such as the facility's name, the date of the nearest available appointment, its location, and the calculated distance from the user's current position.

By selecting a facility from the list, the user is presented with a detailed view that expands on the initial information. This view includes details about the amenities the facility offers, the exact status of the queue, a map view option for directions, and a button for quick access to the facility's phone number.

To further refine their search, users can sort the results by the earliest available date, proximity to their location, or the number of people already waiting for the service. There is also an option to broaden the search to include facilities in neighboring regions, giving users more flexibility when booking an appointment.

<p align="center">
<img src="https://github.com/user-attachments/assets/3babcf76-9e9d-4eb9-8e15-1ddad22e3de1" width="425"/> <img src="https://github.com/user-attachments/assets/9d65b6e1-1a0d-453d-8902-543e643ab5a6" width="425"/> 
</p>

The map view allows the user to see the location of the selected healthcare facility. When zooming out, as shown in, the app also displays the locations of other nearby facilities.

Additionally, the map view offers the option to show the user’s current location and to switch between different map display types, giving users more control over how they navigate and view the available facilities.

<p align="center">
<img src="https://github.com/user-attachments/assets/c0fff31b-81e1-4ab3-a95c-6a5b330a7956" width="425"/>
</p>

This view allows the user to add an appointment to their system calendar. As shown in, it includes a text field with the facility's name automatically filled in. The user can also change filled in time, date, and set duration of the appointment. Additionally, users have the option to include extra details in the event, such as reminders to bring medical history, test results, or other important documents.

<p align="center">
<img src="https://github.com/user-attachments/assets/cb0c669c-d86d-4362-b017-192f249130f3" width="425"/>
</p>

For a detailed walkthrough of the app's features, you can watch the [video presentation here](https://youtu.be/t4G4oD5GkMk?si=-rs5kd4Q34V_BGtm).

All screens in the application are fully compatible with Dynamic Text, allowing users to adjust text size according to their system preferences for better readability. The app also supports VoiceOver, ensuring that visually impaired users can easily navigate and interact with the interface using screen readers. Additionally, the application respects the Reduce Motion setting, minimizing animations and transitions to create a smoother experience for users sensitive to motion effects.
