import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:employeetracking/components/AppBar.dart';
import 'package:employeetracking/components/CachedImage.dart';
import 'package:employeetracking/components/CustomTile.dart';
import 'package:employeetracking/constants.dart';
import 'package:employeetracking/enum/ViewState.dart';
import 'package:employeetracking/models/Employee.dart';
import 'package:employeetracking/models/Message.dart';
import 'package:employeetracking/provider/ImageUploadProvider.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:employeetracking/utils/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Employee receiver;

  ChatScreen({@required this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  bool isWriting = false;
  FirebaseRepository _repository = FirebaseRepository();
  Employee sender;
  String _currentUserEmail;
  ScrollController _listScrollController = ScrollController();
  bool showEmojiPicker = false;
  FocusNode textFieldFocus = FocusNode();
  ImageUploadProvider _imageUploadProvider;

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((user) {
      _currentUserEmail = user.email;
      setState(() async {
        sender = Employee(
          email: await _repository.getCurrentUser().then((user) => user.email),
          uid: user.uid,
          name: await _repository.getProfileName(),
          profilePhoto: await _repository.getProfilePhotoUrl(),
        );
      });
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: <Widget>[
          Flexible(
              child: StreamBuilder(
            stream: Firestore.instance
                .collection(MESSAGES_COLLECTION)
                .document(_currentUserEmail)
                .collection(widget.receiver.email)
                .orderBy(TIMESTAMP, descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              SchedulerBinding.instance.addPostFrameCallback((_) {
                _listScrollController.animateTo(
                    _listScrollController.position.minScrollExtent,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut);
              });

              return ListView.builder(
                controller: _listScrollController,
                reverse: true,
                padding: EdgeInsets.all(10),
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return chatMessageItem(snapshot.data.documents[index]);
                },
              );
            },
          )),
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15),
                  child: CircularProgressIndicator(),
                )
              : Container(),
          chatControls(),
          // showEmojiPicker
          //     ? Container(
          //         child: emojiContainer(),
          //       )
          //     : Container()
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textEditingController.text = textEditingController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(_currentUserEmail)
          .collection(widget.receiver.email)
          .orderBy(TIMESTAMP, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          _listScrollController.animateTo(
              _listScrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 250),
              curve: Curves.easeInOut);
        });

        return ListView.builder(
          controller: _listScrollController,
          reverse: true,
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserEmail
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserEmail
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
          color: UniversalVariables.senderColor,
          borderRadius: BorderRadius.only(
              topLeft: messageRadius,
              topRight: messageRadius,
              bottomLeft: messageRadius)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
            message.message,
            style: TextStyle(fontSize: 16, color: Colors.white),
          )
        : message.photourl != null
            ? CachedImage(url: message.photourl)
            : Text('URL is null');
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
          color: UniversalVariables.senderColor,
          borderRadius: BorderRadius.only(
              topLeft: messageRadius,
              topRight: messageRadius,
              bottomRight: messageRadius)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  pickImage({@required ImageSource imageSource}) async {
    File selectedImage = await Utils.pickImage(imageSource: imageSource);
    _repository.uploadImage(
        image: selectedImage,
        senderId: _currentUserEmail,
        receiverId: widget.receiver.email,
        imageUploadProvider: _imageUploadProvider);
  }

  Widget chatControls() {
    setWritingTo(bool value) {
      setState(() {
        isWriting = value;
      });
    }

    sendMessage() {
      var text = textEditingController.text;

      Message _message = Message(
          receiverId: widget.receiver.email,
          senderId: sender.email,
          message: text,
          timestamp: Timestamp.now(),
          type: 'text');

      setState(() {
        isWriting = false;
      });

      textEditingController.text = '';

      _repository.addMsgToDB(_message, sender, widget.receiver);
    }

    addMediaModel(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: UniversalVariables.blackColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Content and tools',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        onTap: () {
                          pickImage(imageSource: ImageSource.gallery);
                          Navigator.maybePop(context);
                        },
                        title: 'Media',
                        subtitle: 'Share photos and videos',
                        icon: Icons.image,
                      ),
                      ModalTile(
                        title: 'File',
                        subtitle: 'Share files',
                        icon: Icons.tab,
                      ),
                      ModalTile(
                        icon: Icons.contacts,
                        title: 'Contacts',
                        subtitle: 'Share contacts',
                      )
                    ],
                  ),
                )
              ],
            );
          });
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModel(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textEditingController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                // IconButton(
                //   splashColor: Colors.transparent,
                //   highlightColor: Colors.transparent,
                //   onPressed: () {
                //     if (!showEmojiPicker) {
                //       // keyboard is visible
                //       hideKeyboard();
                //       showEmojiContainer();
                //     } else {
                //       //keyboard is hidden
                //       showKeyboard();
                //       hideEmojiContainer();
                //     }
                //   },
                //   icon: Icon(Icons.face,color: UniversalVariables.greyColor,),
                // ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.record_voice_over,
                    color: UniversalVariables.greyColor,
                  ),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(imageSource: ImageSource.camera),
                  child: Icon(
                    Icons.camera_alt,
                    color: UniversalVariables.greyColor,
                  ),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () => sendMessage(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(widget.receiver.name),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.phone),
          onPressed: () {},
        )
      ],
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile(
      {Key key,
      @required this.title,
      @required this.subtitle,
      @required this.icon,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        onTap: onTap,
        mini: false,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: UniversalVariables.receiverColor),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: UniversalVariables.greyColor, fontSize: 14),
        ),
        title: Text(
          title,
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
