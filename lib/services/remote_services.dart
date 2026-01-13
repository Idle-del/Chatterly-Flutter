import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Upload an image to your Django backend
Future<bool> uploadUserImage(File imageFile) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final token = await user.getIdToken(true);

  var uri = Uri.parse('https://kiran117.pythonanywhere.com/api/upload/');
  var request = http.MultipartRequest('POST', uri);

  // Add Firebase token
  request.headers['Authorization'] = 'Bearer $token';

  // Add image file
  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: path.basename(imageFile.path),
    ),
  );

  // Send request
  final response = await request.send();

  if (response.statusCode == 201) {
    return true;
  } else {
    // // Failed to upload
    // final respStr = await response.stream.bytesToString();
    // // print('Upload failed: ${response.statusCode} $respStr');
    return false;
  }
}

/// Fetch the latest uploaded image URL
Future<String?> fetchUserImageUrl() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final token = await user.getIdToken(true);

  final response = await http.get(
    Uri.parse('https://kiran117.pythonanywhere.com/api/my-images/'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return 'https://kiran117.pythonanywhere.com${data['image_url']}';
  } else {
    // print('Failed to fetch image URL: ${response.statusCode}');
    return null;
  }
}

Future<String?> fetchPublicUserImageForUid(String firebaseUid) async {
  final response = await http.get(
    Uri.parse(
      'https://kiran117.pythonanywhere.com/api/public-images/$firebaseUid/',
    ),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['image_url'];
  }
  return null;
}
