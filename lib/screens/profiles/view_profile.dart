import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewProfileImage extends StatefulWidget {
  final String? imageUrl;
  final bool isDark;
  const ViewProfileImage({
    super.key,
    required this.imageUrl,
    required this.isDark,
  });

  @override
  State<ViewProfileImage> createState() => _ViewProfileImageState();
}

class _ViewProfileImageState extends State<ViewProfileImage> {
  bool showControls = false;

  void toggleControls() {
    setState(() {
      showControls = !showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? Colors.grey[900] : Colors.white,
      body: Stack(
        children: [
          ?showControls
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40.0,
                    horizontal: 10,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                )
              : null,
          GestureDetector(
            onTap: toggleControls,
            child: Center(
              child: Image(image: CachedNetworkImageProvider(widget.imageUrl!)),
            ),
          ),
        ],
      ),
    );
  }
}
