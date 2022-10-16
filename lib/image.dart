import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUpload extends StatefulWidget {
  const ImageUpload({Key? key}) : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? image;

  /// Get from gallery
  _getFromGallery() async {
    var pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      print("Image $imageFile");
      setState(() {
        image = imageFile;
      });
      // uploadImageToServer(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    void uploadImageToServer(image) async {
      try {
        print("Image FIle Path Server $image");
        var url = Uri.parse(
            'https://kiranacarts.com/testing-kiranacarts-v1/ShopApi/user_profile_upload/1');

        var stream =
            new http.ByteStream(DelegatingStream.typed(image.openRead()));
        var length = await image.length();
        var request = new http.MultipartRequest("POST", url);

        var multipartFileSign = http.MultipartFile(
            'url_profile', stream, length,
            filename: basename(image.path));

        request.files.add(multipartFileSign);

        request.fields['device_type'] = "android";
        request.fields['gtoken'] = "NBsQomtj3hVPYBu1W5";
        request.fields['login_user_id'] = "1";
        var sendData = await request.send();

        final response = await http.Response.fromStream(sendData);
        print("DATA RES5 ${response.body}");

        if (response.statusCode == 200) {
          print("Successfully Working ");
          print("Response  Body ${response.body}");

          var messsage = ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: new Text("Image Uploaded Successfully ")));
        } else {
          print("response.statusCode_____${response.statusCode}");
          print('faild');
        }
      } catch (e) {
        print("ERROR  ${e.toString()}");
      }
    }

    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Image Upload",
          style: TextStyle(fontSize: 20.0),
        ),
        SizedBox(
          height: 10.0,
        ),
        Center(
          child: InkWell(
            onTap: () {
              _getFromGallery();
            },
            child: Container(
                height: height * 0.4,
                width: width,
                margin: EdgeInsets.all(50),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: (image != null)
                    ? Image.file(image!, fit: BoxFit.fitWidth)
                    : Icon(Icons.photo_album)),
          ),
        ),
        TextButton(
            onPressed: () {
              uploadImageToServer(image);
            },
            child: Text("Upload Button"))
      ],
    ));
  }
}
