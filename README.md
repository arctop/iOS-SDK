# Arctop™ Software Development Kit (SDK)

The Arctop SDK public repository contains everything you need to connect your application to Arctop's services. 

## Background

Arctop is a software company that makes real-time cognition decoding technology. Arctop's software applies artificial intelligence to electric measurements of brain activity, translating people’s feelings, reactions, and intent into actionable data that empower applications with new capabilities. Since its founding in 2016, Arctop has worked to develop a cross-platform SDK that provides noninvasive brain-computer interface capabilities. The SDK is being developed continuously and is the result of  deep R&D, such as [this peer-reviewed study](https://www.frontiersin.org/articles/10.3389/fncom.2021.760561/full) published in _Frontiers in Computational Neuroscience_ where Arctop's SDK was used in a personalized audio application.

The current version of the Arctop SDK provides four unique cognition data streams: focus, enjoyment, flow, and sleep state. It also provides body data streams including eye blinks, heart rate, and heart rate variability. All data streams are provided in real-time, meaning applications receive new data points several times per second. 

In short, Arctop's SDK gives the ability to add new streams of personalized cognition data directly into applications.

Examples of how this data can be used include:
* Developing neurology, psychiatry, and psychology applications.
* Enabling new modes of communication and accessibility features.
* Creating  high performance training scenarios  that are more effective with cognition data in the feedback loop.
* Building generative AI applications to improve foundation models and add empathy and responsiveness to individual preferences in the moment.
* Gaining play-by-play insights into how users respond to products.
* Tracking personal brain health measurements from home.
* Developing novel headwear for gamers.
* Creating adaptive audio applications that tailor sound to user mood.

One way Arctop achieves its high performance analysis is by calibrating data processing models to each new user. This is done through a one-time 10-minute session in Arctop's mobile app that consists of a series of interactive tasks and questions. The calibration process is important since it allows Arctop's AI models of brain function to be individually customized to each user's unique brain data baseline and deliver personalized dynamics measures that are accurate. 

After the one-time calibration, real-time cognition metrics for endless usage are unlocked. For more information about calibration, see the section titled [Verify That a User Has Been Calibrated for Arctop](https://github.com/arctop/ios-sdk#verify-that-a-user-has-been-calibrated-for-arctop) within this file.

## Installation

Add the current project as a Swift package dependency to your own project.

## Package Structure

The SDK contains the following components:

- The *ArctopSDKClient* class is the main entry point to communicate with the sdk. You should create an instance in your application and hold on to it for the duration of the app's lifecycle.

- A set of listener protocols that define the interface of communication.
    - *ArctopSdkListener* defines the callback interface by which the SDK provides responses and notifications back to your app.
    - *ArctopQAListener* defines a callback interface that provides QA values from the sensor device to your app.
    - *ArctopSessionUploadListener* defines a callback interface that provides session upload monitoring.      

## Workflow

> **_NOTE:_**  The SDK is designed to work in a specific flow. 
> The setup phase needs to be done once as long as your application is running. The Session Phase can be done multiple times.

> The SDK is designed to work with the async / await model for asynchronous operations.
### Setup Phase

1. [Prerequisites](#1-prerequisites)
2. [Initialize the SDK with Your API Key](#2-initialize-the-sdk-with-your-api-key)
3. [Register for Callbacks](#3-register-for-callbacks)

### Session Phase

1. [Verify That a User is Logged In](#1-verify-that-a-user-is-logged-in)
2. [Verify That a User Has Been Calibrated for Arctop](#2-verify-that-a-user-has-been-calibrated-for-arctop)
3. [Connect to an Arctop Sensor Device](#3-connect-to-an-arctop-sensor-device)
4. [Verify Signal Quality of Device](#4-verify-signal-quality-of-device)
5. [Begin a Session](#5-begin-a-session)
6. [Work with Session Data](#6-work-with-session-data)
7. [Finish Session](#7-finish-session)

### Cleanup Phase

1. [Shut Down the SDK](#1-shut-down-the-sdk)

## Phase Instructions

### Setup Phase

#### 1. Prerequisites

###### Mobile App
To use the Arctop SDK, you'll need to install the Arctop  app on your mobile device. The Arctop app is available on both the App Store (iOS) and Google Play (Android) and can be found by searching "Arctop".

After downloading the mobile app, use the Sign Up screen to create an account. Follow instructions in the _Supplementary User Instructions_ document provided to you via email for guidance on how to set up and use the mobile app for Arctop streaming.  

###### API Key
You will also need to create an API key in order to use the Arctop SDK with your app. To do so, please submit a request via the Arctop DevKit form provided to you in the “Welcome” email. Feel free to contact us at support@arctop.com with any questions you may have.

#### 2. Initialize the SDK with Your API key

You need an API Key to use Arctop SDK in your app (see [Prerequisites](#1-prerequisites)).
Once you have your API key and are ready to start working with the SDK, you will need to initialize it with your API key by calling **initializeArctop(apiKey:String , bundle:Bundle) async -> Result<Bool,Error>** method of the SDK.

#### 3. Register for Callbacks

While most functions in the SDK are aysnc, some callbacks are reported during normal operations.

Call any of the *func registerListener(listener)* overloads to receive callbacks for different events.

### Session Phase

#### 1. Verify That a User is Logged In 

After successful initialization, your first step is to verify a user is logged in.
You can query the SDK to get the logged in status of a user by calling:

    func isUserLoggedIn() async throws -> Bool

In case the user isn't, launch the login page by calling: 

    func loginUser() async -> Result<Bool, any Error>

This will launch a login page inside an embedded sheet, utilizing AWS Cognito web sign in.
Once complete, if the user has successfully signed in, you can continue your app's flow.

#### 2. Verify That a User Has Been Calibrated for Arctop

Before Arctop services can be used in any sessions, a user must complete calibration to generate their personal Arctop model. This is done via the Arctop app. 

Calibration takes approximately 10 minutes and only needs to be completed once per user. It consists of five short tasks (1-3 minutes each) and is performed while wearing a compatible headwear device to record brain signals throughout. At the end of each task, users are asked to rank their experience using slider scales and short questionnaires.

This process is important for Arctop’s software to learn individual users' unique patterns and tune its algorithms to be as accurate and robust as possible. 

The best practices users should follow when completing calibration are listed below.
* Before starting the calibration session:
    * Go to a quiet place where you will not be interrupted for 10 minutes.
    * Unplug your headwear and mobile device from any chargers.
* During calibration:
    * Try to move as little as possible. Headwear sensors are very sensitive to motion.
    * Do not eat, drink, or close your eyes. It is alright to blink normally.
    * Do not multitask or exit the Arctop app. Focus all of your efforts on the tasks presented. 
    * Complete the session within one sitting and in the same location. Moving around too much during calibration will impact results. 
    * Answer all questions honestly, related to how you felt during the tasks. Calibration takes into account individual user feedback so answer as accurately as you can.

To verify that a user is calibrated, call the service to check the status:
    
    func checkUserCalibrationStatus() async -> Result<UserCalibrationStatus, Error>

The UserCalibrationStatus enum is defined as:

    public enum UserCalibrationStatus: Int{
        case unknown = -100,
             blocked = -1,
             needsCalibration = 0,
             calibrationDone = 1,
             modelsAvailable = 2
    }

A user in the calibrationDone state has finished calibration, which means Arctop's servers are processing their models.
This usually takes around 5 minutes, and then the user is ready to proceed with Arctop live streaming. You cannot start a session for a user that is not in the *modelsAvailable* status.

#### 3. Connect to an Arctop Sensor Device 

Connecting to a Arctop sensor device, for example a headband, is accomplished by calling **func connectSensorDevice(deviceId: String) throws** 

To find available devices, you can initiate a scan using **func scanForAvailableDevices() throws**.
Results will be reported to the SDK Listener via: **func onDeviceListUpdated(museDeviceList: [String])**
The counterpart call **func terminateScanForDevices() throws** can be used to stop an ongoing scan.

The call to **func connectSensorDevice(deviceId: String)** will initiate a series of callbacks to **onConnectionChanged(ConnectionState previousConnection ,ConnectionState currentConnection)**

The values for *previousConnection* and *currentConnection* are defined as:

    public enum ConnectionState:Int {
        case unknown ,
        connecting,
        connected,
        connectionFailed,
        disconnected,
        disconnectedUponRequest
    }

Once the value of *currentConnection == .connected* , you may begin a session. 

To disconnect, you can always call **func disconnectSensorDevice() throws**

#### 4. Verify Signal Quality of Device

Once the device is connected, you should verify that the user's headwear is receiving proper signal. 

The easiest way is to present the user with the **QAView** that is available in the SDK. This SwiftUI view requires bindings that are available via the **QAViewModel** class in the SDK.

You will have to properly connect the model to the view, and feed the model the proper data. This is done as follows:

Declare the model as an **@ObservedObject var qaModel:QAViewModel** in your own view model or other class.
In whichever class you have that implements *ArctopSDKQAListener*, feed the received data into the view model.
The view model has a **qaString** property. You will need to feed the data from **func onSignalQuality(quality: String)** into it.

The view model also has a **isHeadbandOn** property. You will need to feed the data from **func onHeadbandStatusChange(headbandOn: Bool)** into it.
Finally, the QA view model will report back to **onQaPassed() -> Void** which you can assign into to move the process forward.

You should also verify that the user DOES NOT have their device plugged in and charging during sessions, as this causes noise to the signal, and reduces the accuracy of the predictions.

#### 5. Begin a Session

For a calibrated user, call **func startPredictionSession(_ predictionName: String) async -> Result<Bool, Error>** to begin running the Arctop real-time prediction SDK.
You can find the prediction names in **ArctopSDKPredictions**

#### 6. Work with Session Data

At this point, your app will receive results via the **func onValueChanged(key:String, value:Float)** callback.

Users will also be provided with a post-session report and CSV files containing metric data, timestamps, and tags from their most recent session. Reports and CSV files for each session will automatically upload to their Developer Portal. Users can access their centralized session history within their Developer Portal at any time. 

Arctop's focus, enjoyment, flow, sleep, and eye blink metrics are derived exclusively from brain data, while heart rate and heart rate variability metrics are derived from body data. 

Focus, enjoyment, and flow data is provided within the "...Cognition" CSV file. These values range from 0-100. The neutral point for each user is at 50, meaning that values above 50 reflect high levels of the measured quantity. For example, a 76 in focus is a high level of focus, while a 99 is nearly the highest focus that can be achieved. Values below 50 represent the opposite, meaning lack of focus or lack of enjoyment or lack of flow. For example, a 32 in focus is a lower level that reflects the user may not be paying much attention, while a 12 in enjoyment can mean the user dislikes the current experience. A value of 23 in flow indicates that the user is not in a high flow state. 

Sleep data is presented in binary values of 0 or 1 in the "Sleep Detection" column of the provided CSV data file ("...Sleep"). This information tells whether a user is detected to be asleep or awake at each timestamp, with the awake state indicated by a 0 and asleep state indicated by a 1. Focus, enjoyment, flow, and blink metrics are currently unavailable during sleep sessions. No report will be generated for sleep sessions at this time. Additional sleep metrics will be provided in a future version.

Eye blink values are also recorded as a binary. The presence of a blink will be indicated by a value of 1 within the "...Blinks" CSV data file. Blink data for each individual eye will be provided in a future version.

Within the "...Heart Rate" CSV file, heart rate data is provided in units of beats per minute and heart rate variability (HRV) data is provided in units of milliseconds. Heart rate is currently capped at 120 beats per minute; values over this will be displayed as 120.

Any tags added during a session will be provided with their timestamps corresponding to when the user initiated the tag creation. This data is displayed in the "...Tags" CSV file. This file will only be present if tags were added during the session.

Excessively noisy data that cannot be decoded accurately in Arctop’s SDK is represented as either -1 or NaN. These values should be ignored as they reflect low confidence periods of analysis. This can occur for many reasons, such as a lapse in sensor connection to the skin. If you notice an excess of -1 or NaN values in your data, please contact Arctop for support as these values typically only occur on a limited basis.

Signal QA is reported via **func onQAStatus(passed:Bool ,type:QAFailureType)** callback. If QA failed during the analysis window, the **passed** parameter will be false, and the type of failure will be reported in **type**. 

Valid types are defined as:

      public enum QAFailureType : Int {
      case passed = 0
      case headbandOffHead = 1
      case motionTooHigh = 2
      case eegFailure = 3
      
        public var description:String{
            switch self {
            case .passed:
                return "passed"
            case .headbandOffHead:
                return "off head"
            case .motionTooHigh:
                return "moving too much"
            case .eegFailure:
                return "eeg failure"
            }
        }
      }
      
        

#### 7. Finish Session

When you are ready to complete the session, call **func finishSession() async -> Result<Bool, Error>**. 
The session will be uploaded to the server in a background thread and you will receive a response when it has completed.
In case of an error, the SDK will attempt to recover the session at a later time in the background.

### Cleanup Phase

#### 1. Shut Down the SDK

Call **func deinitializeArctop()** to have Arctop release all of its resources.

## Using the SDK Outside of Android and iOS

Arctop™ provides a LAN webserver that allows non-Android, non-iOS clients access to the SDK data. For more info see [Stream Server Docs](https://github.com/arctop/android-sdk/blob/main/Arctop-Stream.md).

It is highly recommended to first read through this documentation to have a better understanding of the SDK before trying to work with the stream server.
