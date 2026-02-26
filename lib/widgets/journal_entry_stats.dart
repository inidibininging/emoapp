import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:flutter/material.dart';

class JournalEntryStats extends StatelessWidget {
  const JournalEntryStats({required this.entries, super.key});
  final List<JournalEntryExtended> entries;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SizedBox(
            width: 600,
            height: 250,
            child: Sparkline(
              data: entries.map((e) => e.emotionalLevel.toDouble()).toList(),
              // backgroundColor: Colors.red,
              // lineColor: Colors.lightGreen[500]!,
              // fillMode: FillMode.below,
              // fillColor: Colors.lightGreen[200]!,
              pointsMode: PointsMode.all,
              pointSize: 5,
              pointColor: Colors.amber,
              useCubicSmoothing: true,
              // lineWidth: 1.0,
              // gridLinelabelPrefix: '\$',
              // gridLineLabelPrecision: 3,
              // enableGridLines: true,
              averageLine: true,
              // kLine: ['max', 'min', 'first', 'last'],
              // // max: 50.5,
              // // min: 10.0,
              enableThreshold: true,
              thresholdSize: 0.1,
              lineGradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple[800]!, Colors.purple[200]!],
              ),
              fillGradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.red[800]!, Colors.red[200]!],
              ),
            ),
          ),
        ),
      );
}
