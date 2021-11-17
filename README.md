<img src="/android/app/src/main/res/mipmap-hdpi/ic_launcher.png" align="left"
     alt="Face recognition">
# Face Recognition Flutter

Realtime face recognition flutter app.

 

## Steps

### Face detection

Used Firebase ML Vision to detect faces .

### Face Recognition

Convert Tensorflow implementation of [MobileFaceNet](https://github.com/sirius-ai/MobileFaceNet_TF) model into tflite.




## Installing


**Step 1:** Download or clone this project
```

**Step 2:** Go to project root and execute the following command in console to get the required dependencies: 
```
flutter pub get 
```

**Step 3:** Add dynamic libraries for flutter_tflite package to work:
[Follow these instructions](https://pub.dev/packages/tflite_flutter#important-initial-setup)


**Step 4:** Install flutter app
```
flutter run 
```


## License

Distributed under the MIT License. See `LICENSE` for more information.

## References

1. <https://github.com/sirius-ai/MobileFaceNet_TF>

2. [Mobile Face Net](https://arxiv.org/ftp/arxiv/papers/1804/1804.07573.pdf)
