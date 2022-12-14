import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:librecamera/main.dart';

class CaptureControlWidget extends StatefulWidget {
  const CaptureControlWidget({
    Key? key,
    required this.controller,
    required this.onTakePictureButtonPressed,
    required this.onVideoRecordButtonPressed,
    required this.onResumeButtonPressed,
    required this.onPauseButtonPressed,
    required this.onStopButtonPressed,
    required this.onNewCameraSelected,
    required this.isVideoCameraSelected,
    required this.isRecordingInProgress,
    required this.leadingWidget,
    required this.isRearCameraSelected,
    required this.setIsRearCameraSelected,
  }) : super(key: key);

  final CameraController? controller;
  final VoidCallback onTakePictureButtonPressed;
  final VoidCallback onVideoRecordButtonPressed;
  final VoidCallback onResumeButtonPressed;
  final VoidCallback onPauseButtonPressed;
  final VoidCallback onStopButtonPressed;
  final Function(CameraDescription) onNewCameraSelected;
  final bool isVideoCameraSelected;
  final bool isRecordingInProgress;
  final Widget leadingWidget;
  final bool isRearCameraSelected;
  final Function() setIsRearCameraSelected;

  @override
  State<CaptureControlWidget> createState() => _CaptureControlWidgetState();
}

class _CaptureControlWidgetState extends State<CaptureControlWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = widget.controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /*CameraTogglesWidget(
            controller: widget.controller,
            onNewCameraSelected: widget.onNewCameraSelected,
          ),*/
        widget.leadingWidget,
        AnimatedRotation(
          duration: const Duration(milliseconds: 400),
          turns: MediaQuery.of(context).orientation == Orientation.portrait
              ? 0
              : 0.25,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: widget.isVideoCameraSelected
                ? () => widget.isRecordingInProgress
                    ? widget.onStopButtonPressed()
                    : widget.onVideoRecordButtonPressed()
                : () => widget.onTakePictureButtonPressed(),
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: widget.isVideoCameraSelected
                      ? Colors.white
                      : Colors.white38,
                  //size: 80,
                  size: 80,
                ),
                Icon(
                  Icons.circle,
                  color:
                      widget.isVideoCameraSelected ? Colors.red : Colors.white,
                  //size: 65,
                  size: 65,
                ),
                Icon(
                  widget.isVideoCameraSelected && widget.isRecordingInProgress
                      ? Icons.stop_rounded
                      : Icons.videocam,
                  color: Colors.white,
                  size: 32,
                ),
                if (!widget.isVideoCameraSelected)
                  Icon(
                    Icons.camera_alt,
                    color: Colors.grey.shade800,
                    size: 32,
                  )
              ],
            ),
            tooltip: widget.isVideoCameraSelected
                ? widget.isVideoCameraSelected && widget.isRecordingInProgress
                    ? AppLocalizations.of(context)!.stopVideo
                    : AppLocalizations.of(context)!.startRecordingVideo
                : AppLocalizations.of(context)!.takePicture,
            iconSize: 80,
          ),
        ),
        AnimatedRotation(
          duration: const Duration(milliseconds: 400),
          turns: MediaQuery.of(context).orientation == Orientation.portrait
              ? 0
              : 0.25,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: widget.isRecordingInProgress
                ? () => cameraController!.value.isRecordingPaused
                    ? widget.onResumeButtonPressed()
                    : widget.onPauseButtonPressed()
                : () {
                    widget.onNewCameraSelected(
                        cameras[widget.isRearCameraSelected ? 1 : 0]);
                    widget.setIsRearCameraSelected();

                    animationController.reset();
                    animationController.forward();
                  },
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.black38,
                  size: 60,
                ),
                widget.isRecordingInProgress
                    ? cameraController!.value.isRecordingPaused
                        ? const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          )
                        : const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 30,
                          )
                    : AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(animationController.value * 6),
                            child: child,
                          );
                        },
                        child: Icon(
                          widget.isRearCameraSelected
                              ? Icons.camera_front
                              : Icons.camera_rear,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
              ],
            ),
            tooltip: widget.isRecordingInProgress
                ? cameraController!.value.isRecordingPaused
                    ? AppLocalizations.of(context)!.resumeVideo
                    : AppLocalizations.of(context)!.pauseVideo
                : widget.isRearCameraSelected
                    ? AppLocalizations.of(context)!.flipToFrontCamera
                    : AppLocalizations.of(context)!.flipToRearCamera,
            iconSize: 60,
          ),
        ),
      ],
    );
  }
}
