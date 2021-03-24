# VVWifiSignalDigram
Wifi signal diagram for both 2.4 GHz and 5 GHz

## Sample usage

- Add diagram on a UIView

```
let type = RadioBandType.fiveGHz
let dataArray: [WifiSSIDModel] = [your data here]

let diagram = WifiSignalDiagram(frame: view.bounds,
                                type: type,
                                data: dataArray,
                                backgroundColor: .white,
                                textColor: .black,
                                titleFontSize: 13)
view.addSubview(diagram)
```

- Add diagram on a UIScrollView

```
let type = RadioBandType.fiveGHz
let dataArray: [WifiSSIDModel] = [your data here]
let frame = scrollView.bounds

let diagram = WifiSignalDiagram(frame: frame,
                                type: type,
                                data: dataArray)

scrollView.addSubview(diagram)
scrollView.contentSize = frame.size
```

## Screenshot


![Screencast](https://ppt.cc/fQwA7x@.png "VVFocusedCollectionView")
