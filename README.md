# channel_monitor

monitor flutter platform channel profiler, include `EventChannel`, `MethodChannel`, and `BinaryChannel`.<br>

## Getting Started

```dart
void main() {
  //add this code to first in your flutter project.
  //note: this code will replace default
  CustomFlutterBinding();
  runApp(MyApp());
}
```

now this package will work and save channel profiler.

## Parse channel profiler data

01. add channel profiler page in your project:

```
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //the channel profiler page
    return BasePage(ChannelDataManager.instance);
  }
}
```

02. dump to it:

![3361635491551_.pic.jpg](./doc/3361635491551_.pic.jpg)


## Other Use

01. Parse channel profiler use web
The [example](./example) support web, you can run it in web and parse channel profiler files in web.
<br>

Note: the web don't support platforms channel, so it can parse channel profiler files form your computer.


## More Config

```dart
ChannelMonitorManager.instance
   ..timeOut = 10 //set monitor time out seconds, default is 5
   ..log = true // default is false
   ..testData =
       false // use test data in Android or iOS, default is false : user your current project data
   ..addIgnoreChannelList("ignorechannle")//add ignore channel name, default is  "flutter/platform", "flutter/navigation"
   ..dataUpload = (path) {
     //the channel profiler will save in app's private dir.
     //it will callback will the data > 10K
     //you can upload data to your service and parse it.

     File file = File(path);
     // upload content to your service
     print("channel data, file: $path \n content: ${file.readAsStringSync()}");

     //if return true, the data will be delete.
     return true;
   };
```

### if you custom `WidgetsFlutterBinding` or `BinaryMessenger`, you can use `ChannelMonitorManager`.
more info, click[custom_flutter_binding](./lib/monitor/custom_flutter_binding.dart)

