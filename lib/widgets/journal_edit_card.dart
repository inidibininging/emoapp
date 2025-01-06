import 'package:emoapp/model/journal_colors.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/services/calendar/day_creator_service.dart';
import 'package:emoapp/view_model/journal_entry_extended_view_model.dart';
// import 'package:emojis_null_safe/emojis.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:hashtagable/widgets/hashtag_text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JournalEditCard extends StatefulWidget {
  const JournalEditCard({required this.journalEntry, Key? key})
      : super(key: key);
  final JournalEntryExtended journalEntry;

  @override
  State<StatefulWidget> createState() => _JournalEditCard();
}

class _JournalEditCard extends State<JournalEditCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.journalEntry.text;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<JournalEntryExtendedViewModel>(
        create: (_) => JournalEntryExtendedViewModel(widget.journalEntry),
        child: Consumer<JournalEntryExtendedViewModel>(
          builder: (context, viewModel, nullableWidget) => Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: const Text(''), //widget.journalEntry.id),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text('Type'),
                    DropdownButton(
                      value: viewModel.type,
                      items: [
                        JournalType.entry.stringRepresentation,
                        JournalType.perspective.stringRepresentation,
                        JournalType.retrospective.stringRepresentation,
                      ]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => viewModel.type =
                          value?.toString() ??
                              JournalType.entry.stringRepresentation,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        text: 'When: ',
                        style: TextStyle(
                          color: secondaryColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: viewModel.timeStamp,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (viewModel.type != JournalType.entry) {
                                  var validDate = DateTime.now();
                                  try {
                                    validDate =
                                        DateFormat().parse(viewModel.timeStamp);
                                  } catch (ex) {}
                                  final days = DayCreatorService.getDays(
                                    validDate.month,
                                    validDate.year,
                                  );

                                  final startDate =
                                      DateFormat('dd.MM.yyyy').parse(
                                    '01.${validDate.month.toString().padLeft(2, '0')}.${validDate.year}',
                                  );

                                  final endDate =
                                      DateFormat('dd.MM.yyyy').parse(
                                    '${days.toString().padLeft(2, '0')}.${validDate.month.toString().padLeft(2, '0')}.${validDate.year}',
                                  );

                                  final nextDate = await showDatePicker(
                                    context: context,
                                    initialDate: validDate,
                                    firstDate: startDate,
                                    lastDate: endDate,
                                  );
                                  if (nextDate != null) {
                                    viewModel.setTimeStamp(nextDate);
                                    await viewModel.save();
                                  }
                                }
                              },
                            // style: const TextStyle(
                            //   color: Colors.deepPurple,
                            //   fontSize: 15,
                            //   fontFamily: 'PlayFair',
                            // ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // SliderTheme(
                    //   data: const SliderThemeData(
                    //     thumbColor: Colors.een,
                    //     thumbShape: RoundSliderThumbShape(
                    //       enabledThumbRadius: 20,
                    //     ),
                    //   ),
                    //   child:
                    Slider(
                      // min: 0,
                      max: 5,
                      value: double.parse(
                        viewModel.emotionalLevel.toString(),
                      ),
                      onChanged: (val) {
                        viewModel.emotionalLevel = val.toInt();
                        setState(() {});
                      },
                    ),
                    // ),
                    // Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Container(
                    //           width: 32,
                    //           child: TextButton(
                    //               onPressed: () =>
                    //                   viewModel.emotionalLevel = 1,
                    //               child: Text(Emojis.frowningFace))),
                    //       Container(
                    //           width: 32,
                    //           child: TextButton(
                    //               onPressed: () =>
                    //                   viewModel.emotionalLevel = 2,
                    //               child:
                    //                   Text(Emojis.slightlyFrowningFace))),
                    //       Container(
                    //           width: 32,
                    //           child: TextButton(
                    //               onPressed: () =>
                    //                   viewModel.emotionalLevel = 3,
                    //               child: Text(Emojis.neutralFace))),
                    //       Container(
                    //           width: 32,
                    //           child: TextButton(
                    //               onPressed: () =>
                    //                   viewModel.emotionalLevel = 4,
                    //               child:
                    //                   Text(Emojis.slightlySmilingFace))),
                    //       Container(
                    //           width: 32,
                    //           child: TextButton(
                    //               onPressed: () =>
                    //                   viewModel.emotionalLevel = 5,
                    //               child: Text(Emojis.smilingFace))),
                    //     ]),
                    const SizedBox(height: 10),

                    // HashTagTextField(
                    TextField(
                      maxLines: 30,
                      // style: const TextStyle(fontFamily: 'Playfair'),
                      decoration: const InputDecoration(
                        labelText: 'How are you today?',
                      ),
                      controller: _controller,
                      onChanged: (value) {
                        viewModel.text = value;
                      },

                      // onDetectionTyped: (text) {
                      //   print(text);
                      // },
                      // onDetectionFinished: () {
                      //   print('finished');
                      // },
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: ElevatedButton(
              key: UniqueKey(),
              // heroTag: 'save_journal',
              child: const Icon(
                Icons.save,
                size: 32,
              ),
              onPressed: () async => Future.sync(() {
                // viewModel.hashtags =
                //     extractHashTags(viewModel.text).toList();
              })
                  .then(
                (value) async => await viewModel.save().then(
                      (value) => Navigator.of(context).pop(),
                    ),
              ),
            ),
          ),
        ),
      );
}
