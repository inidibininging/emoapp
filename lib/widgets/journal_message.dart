// import 'package:emoapp/services/service_locator.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class JournalMessage extends StatefulWidget {
//   final DiscussionMessageExtended DiscussionMessage;
//   JournalMessage({Key? key, required this.DiscussionMessage}) 
// : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _JournalMessage();
// }

// class _JournalMessage extends State<JournalMessage> {
//   final key = GlobalKey();
//   final serviceLocator = ServiceLocatorRegistrar();
//   @override
//   Widget build(BuildContext context) =>
//       ChangeNotifierProvider<DiscussionMessageExtendedViewModel>(
//           create: (_) =>
//               DiscussionMessageExtendedViewModel(widget.DiscussionMessage),
//           child: Consumer<DiscussionMessageExtendedViewModel>(
//               builder: (context, viewModel, nullableWidget) => Card(
//                   color: Colors.transparent,
//                   child: Container(
//                     decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: viewModel.rawType.color.gradient,
//                     )),
//                     child: ListTile(
//                       tileColor: Colors.transparent,
//                       title: Text(viewModel.emotionalLevelAsIcon +
//                           ' ' +
//                           viewModel.text),
//                       subtitle: Text(viewModel.timeStamp),
//                       onTap: () => Navigator.of(context)
//                           .push(MaterialPageRoute(
//                               builder: (context) => JournalEditCard(
//                                   DiscussionMessage: widget.DiscussionMessage)))
//                           .then((value) async => await viewModel.refresh()),
//                     ),
//                   ))));
// }
