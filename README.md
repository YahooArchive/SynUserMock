# SynUserMock

### Features:
* Capture screenshots of each touch interaction
* Annotate your screenshots
* Add a Gaussian Blur to screen shots that contain private data
* Log all network requests and save data to a Charles Proxy session file
* Log the ViewController of each touch interaction
* Log the console output
* Email screenshots (collated in a PDF), Charles session file, console output
* Captures the symbolicated stack trace when a crash occurs and prompts the user to email the logs on next launch

### Setup

```javascript
#import <SynUserMock/SynUserMock.h>

[[SynUserMock sharedInstance] appDidFinishLaunching];
```

Optionally in your uncaughtExceptionHandler you can add the following code to capture crashes
```javascript
void uncaughtExceptionHandler(NSException *exception) 
{
  [[SynUserMock sharedInstance] logUncaughtException:exception];
}
```

Download the sample configuration file and add it to your project. All fields are optional.
  * `SNBSaver` - (String) determines whether to email feedback reports or send to the feedback server. Defaults to 'mail'.
    * `external` - hands sending the report off to SynUserMock's delegate method synUserMockSaveReport:withPresentingViewController:completionBlock.
  * `maxScreenShots` - (String) maximum number of screen shots to capture before the oldest screen shot is purged. Defaults to 15.
  * `maxNetworkLogs` - (String) maximum number of JSON network requests to capture before the oldest network request is purged. Defaults to 15.
  * `bugWindowActivator` - (String) action taken to bring up the create bug view. Defaults to 'SNBWindowActivatorShake'.
    * `SNBWindowActivatorShake` - shake your device to launch the create bug view.

### Usage
To use just shake your device or use a 3 finger tap (depending on how you configured SNB.plist) when your app is running.  You will be shown a series of screenshots that were taken with each touch interaction.  You can annotate a screenshot by tapping on it.  Once finshed hit the create button which will create the logs and PDF.

#### Version History
**1.0**
* Initial version.

Code licensed under the MIT license. See LICENSE file for terms.

