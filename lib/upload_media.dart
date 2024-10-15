import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ffmpeg_demo/created_vdo.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadLongEventMediaScreen extends StatefulWidget {
  const UploadLongEventMediaScreen({super.key});

  @override
  State<UploadLongEventMediaScreen> createState() =>
      _UploadLongEventMediaScreenState();
}

class _UploadLongEventMediaScreenState
    extends State<UploadLongEventMediaScreen> {
  // List infos = [
  //   "upload face image",
  //   "upload image with saree",
  //   "upload face image",
  //   "upload image with saree",
  //   "upload face image",
  //   "upload image with saree",
  // ];

  double? width, height;
  // File? _musicFile;
  File? _mainVideo, _socialMsgVdo;
  VideoPlayerController? _mainVdoController, _socialVdoContainer;
  Map<int, File> imgFiles = {};
  bool combiningVdos = false, gettingData = false;
  File? finalVideo;
  List<String> musicUrls =
      []; // https://storage.googleapis.com/fir-ff637.appspot.com/WhatsApp%20Audio%202024-10-09%20at%207.59.01%20PM.mpeg
  @override
  void initState() {
    super.initState();
    audioData();
    // imgFiles.addAll({0: File(a[0]), 1: File(a[1])});
    _mainVideo = File(
        "https://storage.googleapis.com/namasvi-5d515.appspot.com/meta_event_media/0/videos/2024-09-17T18%3A50%3A40.892104.mp4");
    _mainVdoController = VideoPlayerController.networkUrl(
      Uri.parse(_mainVideo!.path),
    )..initialize().then((_) {
        // Ensure the first frame is shown before displaying the video
        setState(() {});
      });
    _socialMsgVdo = File(
        "https://storage.googleapis.com/namasvi-5d515.appspot.com/meta_event_media/0/videos/2024-09-17T18%3A50%3A40.892104.mp4");
    _socialVdoContainer = VideoPlayerController.networkUrl(
      Uri.parse(_socialMsgVdo!.path),
    )..initialize().then((_) {
        // Ensure the first frame is shown before displaying the video
        setState(() {});
      });
    requestPermissionForMedia();
    requestPermissionForPhotos();
  }

  void audioData() async {
    File a = await copyAssetToTemp('assets/audio1.mpeg');
    selectedMusicUrl = a.path;
    musicUrls.add(selectedMusicUrl);
    if (mounted) {
      setState(() {});
    }
  }
  // Future<void> _selectMusic() async {
  //   final result = await FilePicker.platform
  //       .pickFiles(type: FileType.audio, allowMultiple: false);

  //   if (result != null) {
  //     setState(() {
  //       _musicFile = File(result.files.single.path!);
  //     });
  //   }
  // }
  bool creatingVdo = false;
  String selectedMusicUrl = "";
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlayingMusic = false;
  // Function to play music
// Function to play music
  void playMusic() async {
    isPlayingMusic = true;
    await audioPlayer.play(
        UrlSource(selectedMusicUrl)); // Use UrlSource to wrap the URL string
  }

  // Function to stop music
  void stopMusic() async {
    isPlayingMusic = false;
    await audioPlayer.stop();
  }

  Widget musicDropDown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dropdown for selecting music
        SizedBox(
          width: width! / 1.5,
          child: DropdownButton<String>(
            hint: const Text('Select Music'),
            value: selectedMusicUrl.isEmpty ? null : selectedMusicUrl,
            onChanged: (String? newValue) {
              setState(() {
                selectedMusicUrl = newValue!;
              });
            },
            items: musicUrls.map<DropdownMenuItem<String>>((String url) {
              return DropdownMenuItem<String>(
                value: url,
                child: Text(
                  url.length > 30 ? url.substring(0, 30) : url,
                  style: const TextStyle(fontSize: 10),
                ), // Show only file name
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        // Button to stop music
        // ElevatedButton(
        //   onPressed: stopMusic,
        //   child: Text(
        //     'Stop Music',
        //     style: TextStyle(fontSize: 12),
        //   ),
        // ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (isPlayingMusic) {
                stopMusic();
              } else {
                if (selectedMusicUrl.isNotEmpty) {
                  playMusic();
                }
              }
            });
          },
          child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(
                !isPlayingMusic
                    ? Icons.play_circle_fill
                    : Icons.pause_circle_filled,
                size: 40,
                color: Colors.white,
              )),
        )
      ],
    );
  }

  Future<void> _pickImage(int index) async {
    try {
      //  await requestPermissionForPhotos();
      // PermissionStatus permissionStatus;

      // if (Platform.isAndroid) {
      //   final androidInfo = await DeviceInfoPlugin().androidInfo;

      //   if (androidInfo.version.sdkInt <= 32) {
      //     permissionStatus = await Permission.storage.request();
      //   } else {
      //     permissionStatus = await Permission.manageExternalStorage.request();
      //   }
      // print(
      //     " androidInfo.version.sdkInt = ${androidInfo.version.sdkInt} , permissionStatus.isGranted = ${permissionStatus.isGranted}");
      // if (permissionStatus.isGranted) {
      // if (await Permission.photos.isGranted ||
      //     await Permission.storage.isGranted) {

      await FilePicker.platform
          .pickFiles(
        allowedExtensions:
            await _isAndroid12OrAbove() ? null : ['jpg', 'jpeg', 'png'],
        type: await _isAndroid12OrAbove() ? FileType.image : FileType.custom,
        allowMultiple: false, // Disable multiple selection for one-by-one
      )
          .then((pickedFile) {
        if (pickedFile != null && pickedFile.files.isNotEmpty) {
          setState(() {
            imgFiles.addAll({
              index: File(pickedFile.files.first.path!)
            }); // Save the file path in the list
          });
        }
      }).catchError((err) {
        print(err);
      });
      // } else {
      //   _showSnackbar(context, "Permission denied");
      // }
      // If a file is selected, add it to the list
      // } else if (permissionStatus.isPermanentlyDenied) {
      //   _showSnackbar(context,
      //       "Permission denied permanently, goto setting and grant permission");
      // } else {
      //   print(permissionStatus);
      // }
      // }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> requestPermissionForMedia() async {
    if (Platform.isAndroid && await _isAndroid12OrAbove()) {
      // For Android 13 and above, request READ_MEDIA_VIDEO permission
      var status = await Permission.videos.request();

      if (status.isGranted) {
        print("Video access permission granted");
        // Proceed to pick a video
      } else {
        print("Video access permission denied");
      }
    } else {
      // For Android versions below 13, request READ_EXTERNAL_STORAGE
      var status = await Permission.storage.request();

      if (status.isGranted) {
        print("Storage permission granted");
        // Proceed to pick a video
      } else {
        print("Storage permission denied");
      }
    }
  }

  Future<void> requestPermissionForPhotos() async {
    if (Platform.isAndroid && await _isAndroid12OrAbove()) {
      // For Android 13 and above, request READ_MEDIA_IMAGES permission
      var status =
          await Permission.photos.request(); // For photos in Android 13+

      if (status.isGranted) {
        print("Photo access permission granted");
        // Proceed to pick a photo
      } else {
        print("Photo access permission denied");
      }
    } else {
      // For Android versions below 13, request READ_EXTERNAL_STORAGE
      var status = await Permission.storage
          .request(); // For photos in Android 12 or below

      if (status.isGranted) {
        print("Storage permission granted");
        // Proceed to pick a photo
      } else {
        print("Storage permission denied");
      }
    }
  }

  Future<bool> _isAndroid12OrAbove() async {
    // Check if the Android version is 13 (API 33) or higher
    return Platform.isAndroid && (await _getAndroidVersion()) > 12;
  }

  Future<int> _getAndroidVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    return int.parse(androidInfo.version.release);
  }

  Future<void> _pickVideo(bool isMain) async {
    try {
      FilePickerResult?
          // bool status = await Permission.videos.request().isGranted;
          // print("status  = $status");
          // if (status) {
          // if (await Permission.videos.isGranted ||
          //     await Permission.storage.isGranted) {

          pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.video, // Specify that only video files should be picked
        allowMultiple:
            false, // Set to true if you want to allow multiple videos
      );

      if (pickedFile != null && pickedFile.files.isNotEmpty) {
        if (isMain) {
          _mainVideo = File(pickedFile.files.single.path!);
          _mainVdoController = VideoPlayerController.file(
            File(_mainVideo!.path),
          )..initialize().then((_) {
              // Ensure the first frame is shown before displaying the video
              setState(() {});
            });
        } else {
          _socialMsgVdo = File(pickedFile.files.single.path!);
          _socialVdoContainer = VideoPlayerController.file(
            File(_socialMsgVdo!.path),
          )..initialize().then((_) {
              // Ensure the first frame is shown before displaying the video
              setState(() {});
            });
        }
      }
      // } else {
      //   _showSnackbar(context, "Permission denied ");
      // }
      // } else if (await Permission.videos.request().isPermanentlyDenied) {
      //   _showSnackbar(context,
      //       "Permission denied permanently, goto setting and grant permission");
      // } else {
      //   print(await Permission.videos.request());
      // }
    } catch (e) {
      rethrow;
    }
  }

  Future<File> copyAssetToTemp(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = '${tempDir.path}/${assetPath.split('/').last}';
    final File tempFile = File(tempPath);
    await tempFile.writeAsBytes(data.buffer.asUint8List());
    return tempFile;
  }

  Future<void> createVideoFromImages(List<File> imagePaths,
      {int secondsPerImage = 1}) async {
    final directory = await getTemporaryDirectory();
    String imagesListFile = '${directory.path}/images.txt';
    String outputVideoPath = '${directory.path}/output_video.mp4';
    final outputFile = File(outputVideoPath);

    // Delete the output file if it exists
    if (await outputFile.exists()) {
      await outputFile.delete();
    }

    // Create the text file with image paths
    String imagesPath = imagePaths
        .map((image) => "file '${image.path}'\nduration $secondsPerImage")
        .join('\n');
    // Append the last image without duration to avoid an extra delay at the end
    imagesPath += "\nfile '${imagePaths.last.path}'";

    File(imagesListFile).writeAsStringSync(imagesPath);

    String command = '-y -f concat -safe 0 -i $imagesListFile '
        '-vf "scale=720:1280:force_original_aspect_ratio=decrease,pad=720:1280:(ow-iw)/2:(oh-ih)/2,format=yuv420p" '
        '-r 30 -c:v libx264 -qscale:v 2 -pix_fmt yuv420p $outputVideoPath';

    final session = await FFmpegKit.execute(command);
    var returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      print('Video created successfully from images!');
      await combineVideos(
          outputVideoPath, _mainVideo!.path, _socialMsgVdo!.path);
    } else {
      // session.getAllLogs().then((logs) {
      //   for (var log in logs) {
      //     print("FFmpeg Log: ${log.getMessage()}");
      //   }
      // });

      _showSnackbar(context, "Error while merging images");
    }
  }

  int percentageAmount = 0;
  Future<void> combineVideos(
      String videoPath1, String videoPath2, String videoPath3) async {
    final directory = await getTemporaryDirectory();
    String outputFinalVideoPath = '${directory.path}/output_final_video.mp4';

    // Delete the final output file if it exists
    final finalOutputFile = File(outputFinalVideoPath);
    if (await finalOutputFile.exists()) {
      await finalOutputFile.delete();
    }
    String command =
        '-y -i $videoPath1 -i $videoPath2 -i $selectedMusicUrl -i $videoPath3 ' +
            '-filter_complex "[0:v]scale=480:854,setsar=1[video1]; ' +
            '[1:v]scale=480:854,setsar=1[video2]; ' +
            '[3:v]scale=480:854,setsar=1[video3]; ' +
            '[video1][video2]concat=n=2:v=1:a=0[concatv]; ' +
            '[concatv][video3]concat=n=2:v=1:a=0[outv]; [2:a]volume=1.5[audio]" ' +
            '-map "[outv]" -map "[audio]" -c:a aac -b:a 128k -c:v libx264 -b:v 1000k -preset ultrafast -r 15 -shortest $outputFinalVideoPath';

    final session = await FFmpegKit.execute(command);
    var returnCode = await session.getReturnCode();
    // print("returnCode = ${returnCode!.getValue()}");
    if (ReturnCode.isSuccess(returnCode)) {
      print('Final video created successfully with the third video added!');

      Navigator.push(context, CupertinoPageRoute(builder: (context) {
        return VideoPlayerItem(videoUrl: outputFinalVideoPath);
      }));
    } else {
      // session.lo().then((logs) {
      //   for (var log in logs) {
      //     print("FFmpeg Log: ${log.getMessage()}");
      //   }
      // });
      _showSnackbar(context, "Error while merging videos");
    }
  }

  void _showSnackbar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Code to execute when the action is pressed
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Creates the final video by combining images and a main video.
  void createFinalVideo() async {
    try {
      setState(() {
        combiningVdos = true;
      });
      if (imgFiles.isEmpty) {
        List<File> imgs = [];
        for (int i = 0; i < a.length; i++) {
          final File img = await copyAssetToTemp(a[i]);
          imgs.add(img);
        }
        await createVideoFromImages(imgs);
      } else {
        List<File> imgs = [];
        for (int i = 0; i < imgFiles.length; i++) {
          // imagePaths.add(imgFiles[i]!.path);
          imgs.add(imgFiles[i]!);
        }
        await createVideoFromImages(imgs);
      }
    } catch (e) {
      setState(() {
        combiningVdos = false;
      });
      rethrow;
    } finally {
      setState(() {
        combiningVdos = false;
      });
    }
  }

  List a = ["assets/download1.png", "assets/download1.png"];
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return SafeArea(
        top: false,
        child: Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
            child: OutlinedButton(
              child: combiningVdos
                  ? SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        color: Colors.purple.shade300,
                      ),
                    )
                  : const Text("GET VIDEO"),
              onPressed: () {
                combiningVdos ? null : createFinalVideo();
              },
            ),
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text("FFMPEG"),
          ),
          body: gettingData
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.purple.shade300,
                ))
              : ListView(
                  padding: const EdgeInsets.all(15.0),
                  children: [
                    const Text(
                      "Image Upload",
                      style: TextStyle(
                          // fontFamily: latoFont,
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Wrap(
                        spacing: 10.0, // Horizontal space between images
                        runSpacing:
                            10.0, // Vertical space between rows of images
                        children: a.asMap().entries.map((entry) {
                          return returnUploadView(entry.key, entry.value, false,
                              false, entry.value);
                        }).toList()),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      "Video Uploaded",
                      style: TextStyle(
                          // fontFamily: latoFont,
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Main Video",
                      style: TextStyle(
                          // fontFamily: latoFont,
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: returnUploadViewVdo(true, _mainVideo,
                          _mainVdoController, 0, "Upload Main Video Here", ""),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      "Social Msg Video",
                      style: TextStyle(
                          // fontFamily: latoFont,
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: returnUploadViewVdo(
                            false,
                            _socialMsgVdo,
                            _socialVdoContainer,
                            1,
                            "Upload Social Msg Video Here",
                            "")),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      "Select Music",
                      style: TextStyle(
                          // fontFamily: latoFont,
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2),
                    ),
                    musicDropDown(),
                  ],
                ),
        ));
  }

  Widget returnUploadView(
      int index, String txt, bool isVdo, bool isMain, String img) {
    String? fileExtension =
        imgFiles[index] == null ? null : imgFiles[index]!.path.split('.').last;

    bool containsExtension = fileExtension == null
        ? false
        : ['jpg', 'jpeg', 'png'].contains(fileExtension);
    return imgFiles[index] != null && containsExtension
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 102,
              height: 100,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.file(
                    File(imgFiles[index]!.path),
                    width: 102,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  belowPhotoOrContainerRow(index, txt, false, false)
                ],
              ),
            ))
        : ImgContainer(index, txt, false, false, img);
  }

  Widget ImgContainer(
      int index, String txt, bool isVdo, bool isMain, String img) {
    return UnconstrainedBox(
      child: Container(
          alignment: Alignment.bottomCenter,
          width: 102,
          height: 100,
          decoration: BoxDecoration(
              image: img.isEmpty
                  ? null
                  : DecorationImage(
                      image: AssetImage(img), // Replace with your image URL
                      fit: BoxFit.cover, // Adjust the fit as needed
                    ),
              color: const Color(0xffD9D9D9),
              borderRadius: BorderRadius.circular(12)),
          child: belowPhotoOrContainerRow(index, txt, isVdo, isMain)),
    );
  }

  Widget belowPhotoOrContainerRow(
      int index, String txt, bool isVdo, bool isMain) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // DesignConfig.showInfoDialog(context, txt);
            },
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (isVdo) {
                _pickVideo(isMain);
              } else {
                await _pickImage(index);
              }
            },
            child: Icon(
              Icons.add_circle_outlined,
              color: Colors.purple.shade300,
              size: 18,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mainVdoController?.dispose(); // Dispose controller when widget is disposed
    _socialVdoContainer?.dispose();
    super.dispose();
  }

  Widget returnUploadViewVdo(bool isMain, File? vdo,
      VideoPlayerController? controller, int index, String txt, String img) {
    return vdo != null && controller != null && controller.value.isInitialized
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 102,
              height: 100,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(controller),
                  belowPhotoOrContainerRow(index, txt, true, isMain),
                  Positioned(
                    top: 35,
                    child: SizedBox(
                      height: 20,
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.black,
                        onPressed: () {
                          setState(() {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                          });
                        },
                        child: Icon(
                          controller.value.isInitialized
                              ? controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow
                              : null,
                          size: 14,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ))
        : ImgContainer(index, txt, true, isMain, img);
  }
}
