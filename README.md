# Arctop™ Software Development Kit (SDK)

The Arctop SDK public repository contains everything you need to connect your application to Arctop SDKs. 

# Background

Arctop is a noninvasive neural interface technology that is the fruit of deep R&D performed by Arctop Inc. It is fully working, developed, and comes out of proven research — a reference you may find helpful is a peer-reviewed article in Frontiers in Computational Neuroscience where Arctop SDK was used for a personalized audio application: https://www.frontiersin.org/articles/10.3389/fncom.2021.760561/full

The current version of Arctop provides three unique brain data streams: Focus, Enjoyment, and 'The Zone' (aka flow-state). It also provides streams of body data: Head Motion - which is composed of both Gyroscope and Accelerometer data, also available as raw sensor data. All in real-time! Meaning new data points several times a second. This new data can be used to, for example, monitor brain health from home, create adaptive features that enhance applications by making them "smarter" and more user-centric, or during app development to quantitatively a/b test different  experiences.

In short, Arctop brings a new stream of information direct from brain to computer and it can be used to power all sorts of applications/uses.

One way Arctop achieves its high performance analysis is by calibrating itself to each new user. This allows the brain pattern analysis that Arctop performs to be customized and take into account each person's baseline. More information about the calibration is provided in the section [Verify a user is calibrated for Arctop](https://github.com/arctop/ios-sdk#verify-a-user-is-calibrated-for-arctop). Calibration is required only one-time for each user and takes approximately 10 minutes to complete.

# Installation

Add the current project as a swift package dependency to your own project.

# Package structure

The SDK contains the following components:

- The *ArctopSDKClient* class is the main entry point to communicate with the sdk. You should create an instance in your application and hold on to it for the duration of the app's lifecycle.

- A set of listener protocols that define the interface of communication.
    - *ArctopSdkListener* defines the callback interface by which the SDK provides responses and notifications back to your app.
    - *ArctopQAListener* defines a callback interface that provides QA values from the sensor device to your app.
    - *ArctopSessionUploadListener* defines a callback interface that provides session upload monitoring.      

# Workflow

> **_NOTE:_**  The SDK is designed to work in a specific flow. 
> The setup phase needs to be done once as long as your application is running. The session phase can be done multiple times.

> The SDK is designed to work with the async / await model for asynchronous operations.
## Setup Phase

1. [Initialize the SDK with your API key](#initialize-the-sdk-with-your-api-key)
2. [Register for callbacks](#register-for-callbacks)

## Session Phase

1. [Verify that a user is logged in](#verify-a-user-is-logged-in)
2. [Verify that a user has been calibrated for Arctop](#verify-a-user-is-calibrated-for-arctop)
3. [Connect to a Arctop sensor device](#connect-to-a-arctop-sensor-device)
4. [Verify Signal Quality of device](#verify-signal-quality-of-device)
5. [Begin a session](#begin-a-session)
6. [Work with session data](#work-with-session-data)
7. [Finish session](#finish-session)

## Cleanup

1. [Shutdown the SDK](#shutdown-the-sdk)

### Setup Phase


#### Initialize the SDK with your API key

You need an API Key to use Arctop SDK in your app.
Once you have your API key and are ready to start working with the SDK, you will need to initialize it with your API key by calling **initializeArctop(apiKey:String , bundle:Bundle) async -> Result<Bool,Error>** method of the SDK.

#### Register for callbacks

While most functions in the SDK are aysnc, some callbacks are reported during normal operations.

Call any of the *func registerListener(listener)* overloads to receive callbacks for different events.

### Session Phase

#### Verify a user is logged in 

After successful initialization, your first step is to verify a user is logged in.
You can query the SDK to get the logged in status of a user by calling:

    func isUserLoggedIn() async throws -> Bool

In case the user isn't, launch the login page by calling: 

    func loginUser() async -> Result<Bool, any Error>

This will launch a login page inside an embedded sheet, utilizing AWS Cognito web sign in.
Once complete, if the user has successfully signed in, you can continue your app's flow.

#### Verify a user is calibrated for Arctop

Before Arctop SDKs can be used in any sessions, a user must complete calibration and have personal Arctop models generated for them. This is done via the Arctop app. To calibrate, in the Arctop  app users will go through a short session:
    
The calibration process is approximately 10 minutes long and asks users to complete a few short tasks (1-3 minutes each) while their brain signal is recorded by a compatible headband or other sensor device. At the end of each task users are asked to rank their experience using slider scales and questionairres. 
    
This process is crucial in order for Arctop to learn individual users and adjust its algorithms to be as accurate and robust as possible. Therefore, it is important that users complete this session while they are in a quiet place, with no disruptions, and making sure the headband is positioned properly.

To verify that a user is calibrated, call the SDK to check the status:
    
    func checkUserCalibrationStatus() async -> Result<UserCalibrationStatus, Error>

The UserCalibrationStatus enum is defined as:

    public enum UserCalibrationStatus: Int{
        case unknown = -100,
             blocked = -1,
             needsCalibration = 0,
             calibrationDone = 1,
             modelsAvailable = 2
    }

A user in the calibrationDone state has finished calibration and Arctop's servers are processing their models.
This usually takes around 5 minutes and then the user is ready to proceed with live streaming. You cannot start a session for a user that is not in the *modelsAvailable* status.

#### Connect to a Arctop sensor device 

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

#### Verify Signal Quality of device

Once the device is connected you should verify that the user it is receiving proper signal. 
The easiest way is to present the user with the **QAView** that is available in the SDK. This SwiftUI view requires bindings that are available via the **QAViewModel** class in the SDK.

You will have to properly connect the model to the view, and feed the model the proper data. This is done as follows:

Declare the model as an **@ObservedObject var qaModel:QAViewModel** in your own view model or other class.
In whichever class you have that implements *ArctopSDKQAListener*, feed the received data into the view model.
The view model has a **qaString** property. You will need to feed the data from **func onSignalQuality(quality: String)** into it.
The view model also has a **isHeadbandOn** property. You will need to feed the data from **func onHeadbandStatusChange(headbandOn: Bool)** into it.
Finally, the QA view model will report back to **onQaPassed() -> Void** which you can assign into to move the process forward.

You should also verify that the user DOES NOT have their device plugged in and charging during sessions, as this causes noise to the signal, and reduces the accuracy of the predictions.
#### Begin a session

For a calibrated user, call **func startPredictionSession(_ predictionName: String) async -> Result<Bool, Error>** to begin running the Arctop real-time prediction SDK.
You can find the prediction names in **ArctopSDKPredictions**

#### Work with session data

At this point, your app will receive results via the **func onValueChanged(key:String, value:Float)** callback.

Results are given in the form of values from 0-100 for Focus & Enjoyment. The neutral point for each user is at 50, meaning that values above 50 reflect high levels of the measured quantity, for example a 76 in Focus is a high level of Focus. Values below 50 represent the opposite, meaning lack of focus or lack of enjoyment. For example a 32 in Focus is a low level that reflects the user not paying attention, a 12 in Enjoyment means the user really dislikes whatever is happening. Low Zone levels reflect being distracted or generally not immersed in an experience.

Values of -1 or NaNs should be ignored as these reflect low confidence periods of analysis. This can occur for any reason, including a momentary lapse in sensor connection or a brain response that is anomalous. Arctop is strict and always prefers to say "I don't know" with a -1 or NaN rather than imply that it knows by giving a value which has a high chance of being inaccurate. If you notice an excess of -1s or NaNs in your data please contact Arctop for support as these values should occur only very limitedly.

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
      
        

#### Finish session

When you are ready to complete the session, call **func finishSession() async -> Result<Bool, Error>**. 
The session will be uploaded to the server in a background thread and you will receive a response when it has completed.
In case of an error, the SDK will attempt to recover the session at a later time in the background.
### Cleanup

#### Shutdown the SDK

Call **func deinitializeArctop()** to have Arctop release all of its resources.

# Using the SDK with a non iOS Client

Arctop™ provides a LAN webserver that allows non iOS clients access to the SDK data. For more info see [Stream Server Docs](https://github.com/arctop/android-sdk/blob/main/Arctop-Stream.md).

It is highly recommended to first read through this documentation to have a better understanding of the SDK before trying to work with the stream server.
