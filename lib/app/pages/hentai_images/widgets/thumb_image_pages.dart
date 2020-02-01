import 'package:flutter/material.dart';
import 'package:flutter_imagenetwork/flutter_imagenetwork.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:thehentaiworld/app/shared_module/thehentaiworld.service.dart';

class ThumbImagePages extends StatefulWidget {
  final List<ThumbData> thumbs;
  final bool full;
  final int initialPage;
  final Function(int page) onTap;
  final BoxFit fit;

  const ThumbImagePages({
    Key key,
    this.thumbs,
    this.full = false,
    this.initialPage = 0,
    this.onTap,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  _ThumbImagePagesState createState() => _ThumbImagePagesState();
}

class _ThumbImagePagesState extends State<ThumbImagePages> {
  PageController _pageController;
  int currentPage = 0;
  Matrix4 transform = Matrix4.identity();

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _pageController = PageController(
      initialPage: currentPage,
      viewportFraction: widget.full ? 1 : 0.93,
    );

    _pageController.addListener(() {
      int next = _pageController.page.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  _resetSize(_) {
    setState(() {
      transform = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MatrixGestureDetector(
      // 更改通知回调
      onMatrixUpdate: (m, tm, sm, rm) {
        setState(() {
          transform = MatrixGestureDetector.compose(transform, tm, sm, null);
        });
      },
      shouldRotate: false,
      focalPointAlignment: Alignment.center,
      child: Scaffold(body: _pageView()),
    );
  }

  Widget _pageView() {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: _pageController,
      itemCount: widget.thumbs.length,
      onPageChanged: widget.full ? _resetSize : null,
      itemBuilder: (context, int index) {
        bool active = currentPage == index;
        return _buildThumbPage(widget.thumbs[index], active, index);
      },
    );
  }

  Widget _buildThumbPage(ThumbData thumb, bool active, int index) {
    Widget _result;

    if (widget.full) {
      _result = Transform(
        key: ObjectKey(thumb),
        transform: transform,
        child: AjanuwImage(
          image: AjanuwNetworkImage(thumb.originalImage),
          fit: widget.fit,
          loadingWidget: AjanuwImage.defaultLoadingWidget,
          loadingBuilder: AjanuwImage.defaultLoadingBuilder,
          errorBuilder: AjanuwImage.defaultErrorBuilder,
        ),
      );
    } else {
      final double blur = active ? 20 : 0;
      final double offset = active ? 1 : 0;
      final double top = active ? 10 : 20;
      _result = GestureDetector(
        key: ObjectKey(thumb),
        onTap: () => widget.onTap(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOutQuint,
          margin: EdgeInsets.only(
            top: top,
            bottom: top,
            left: 6,
            right: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(
              image: NetworkImage(thumb.originalImage),
              fit: widget.fit,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: blur,
                offset: Offset(offset, offset),
              ),
            ],
          ),
        ),
      );
    }

    return _result;
  }
}
