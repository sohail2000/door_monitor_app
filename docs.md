# USB Door Monitor Application Documentation

## Table of Contents

1. [Overview](#overview)
2. [Main Components](#main-components)
   - [main.dart](#maindart)
   - [usb_service.dart](#usbservicedart)
3. [Data Flow](#data-flow)
   - [1. USB Connection](#1-usb-connection)
   - [2. Connecting to a Device](#2-connecting-to-a-device)
   - [3. Data Transmission](#3-data-transmission)
   - [4. Updating the UI](#4-updating-the-ui)
4. [User Interface](#user-interface)
5. [How to Use](#how-to-use)
6. [Conclusion](#conclusion)

## Overview

The **USB Door Monitor Application** is a Flutter-based mobile app that connects to USB serial devices to monitor the status of multiple doors in real-time. The app provides a user-friendly interface to view the status of each door and manage USB device connections seamlessly.

## Main Components

### `main.dart`

This file serves as the primary interface for users and is responsible for managing the application's state and displaying the UI.

- **MyApp**: The main widget that initializes the application.
- **MyAppState**: The state class that manages the connection status and updates the UI accordingly. Key functionalities include:
  - Initializing the USB listener to detect device connections.
  - Updating the list of available USB ports and their statuses.
  - Displaying door statuses using a grid layout.

### `usb_service.dart`

This file encapsulates all logic related to USB communication and device management.

- **UsbService Class**: Manages the USB port connection and the parsing of door status messages.
  - **Fields**:
    - `_port`: Represents the current USB port connection.
    - `ports`: A list of widgets representing available USB devices.
    - `doorStatus`: A map that holds the current open/closed status of each door.
    - `_subscription`, `_transaction`, and `_device`: Handle the data stream and manage the connected USB device.

- **Methods**:
  - `connectTo(UsbDevice? device)`: Establishes a connection to the specified USB device, sets communication parameters, and begins listening for data.
  - `parseDoorStatus(String data)`: Processes incoming data to update the door statuses based on regex matching.
  - `initPortsListener(Function(List<Widget>) updatePorts)`: Sets up a listener for USB device events and retrieves the available ports.
  - `getPorts(Function(List<Widget>) updatePorts)`: Retrieves a list of available USB devices and updates the UI accordingly.
  - `dispose()`: Cleans up resources by disconnecting from the USB device.

## Data Flow

### 1. USB Connection

- When the application starts, `UsbService` initializes a listener on the USB event stream provided by the `usb_serial` package. This listener responds to any changes in connected USB devices (e.g., devices plugged in or removed).

### 2. Connecting to a Device

- The application retrieves the list of available USB devices through `UsbSerial.listDevices()`.
- The UI displays these devices in a list format, with each device having a "Connect" button.
- When the user presses the "Connect" button for a specific device, the `connectTo()` method in `UsbService` is called, which handles the connection process and sets parameters such as baud rate, data bits, stop bits, and parity.

### 3. Data Transmission

- After successfully connecting to the device, the app sets up a `Transaction` object that listens for incoming data from the USB device.
- The data received is expected to follow a specific format, e.g., `door1:open`, `door2:closed`, etc. This data is parsed in real-time using the `parseDoorStatus()` method, which utilizes regular expressions to update the `doorStatus` map.

### 4. Updating the UI

- Whenever a change in door status is detected, the application updates the UI to reflect the new statuses of the doors.
- The door statuses are displayed in a grid format, where each door is represented by a card indicating its current state (open or closed) with appropriate colors (green for open and red for closed).

## User Interface

The main user interface of the application consists of the following components:

- **AppBar**: Displays the title of the application, "Door Monitor."
- **Available Serial Ports Section**: Lists available USB devices with options to connect or disconnect.
- **Door Status Grid**: A grid displaying each door's current status (open/closed) using icons and colors to provide a visual cue for the user.

## How to Use

1. **Installation**: Clone the repository and ensure all dependencies are installed by running `flutter pub get`.
2. **Connection**: Connect your USB device to the mobile device running the app. 
3. **Launch the App**: Run the application using `flutter run`.
4. **Monitor Doors**: Observe the list of available USB ports. Click "Connect" on a device to start monitoring door statuses.
5. **View Statuses**: The status of each door will be updated in real-time on the grid displayed in the app.

## Conclusion

The USB Door Monitor Application is an efficient tool for monitoring door statuses via USB serial communication. It provides a clear and intuitive interface while abstracting the complexity of USB communication and data parsing through the `UsbService` class. This modular architecture allows for easy updates and maintenance, making it suitable for future enhancements and features.
