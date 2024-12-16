import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../Fire_Services/FireStoreService.dart';

class Charts extends StatefulWidget {
  Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  final firestoreService = FirestoreService();

  // Fetch data from Firestore
  Future<Map<String, int>> getData() async {
    final data = await firestoreService.fetchOrderData();
    return data;
  }

  // Function to generate a list of colors for charts
  List<Color> generateColors(int length) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
      Colors.pink,
    ];
    return List.generate(length, (index) => colors[index % colors.length]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Product Sales Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: FutureBuilder<Map<String, int>>(
                future: getData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available.'));
                  }

                  final aggregatedData = snapshot.data!;
                  final colors = generateColors(aggregatedData.length);

                  // Prepare the pie chart data
                  List<PieChartSectionData> pieSections = aggregatedData.entries.map((entry) {
                    final productName = entry.key;
                    final quantitySold = entry.value;
                    final color = colors[aggregatedData.keys.toList().indexOf(productName)];

                    return PieChartSectionData(
                      value: quantitySold.toDouble(),
                      color: color,
                      title: '$productName\n$quantitySold',
                      radius: MediaQuery.of(context).size.width * 0.25,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    );
                  }).toList();

                  // Prepare the bar chart data
                  List<BarChartGroupData> barGroups = aggregatedData.entries.map((entry) {
                    final index = aggregatedData.keys.toList().indexOf(entry.key);
                    final quantitySold = entry.value;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: quantitySold.toDouble(),
                          color: colors[index],
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList();

                  return Column(
                    children: [
                      // Pie Chart Section
                      Expanded(
                        flex: 1,
                        child: PieChart(
                          PieChartData(
                            sections: pieSections,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: MediaQuery.of(context).size.width * 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),

                      // Bar Chart Section
                      Expanded(
                        flex: 1,
                        child: BarChart(
                            BarChartData(
                              maxY: aggregatedData.values.reduce((a, b) => a > b ? a : b).toDouble() + 5,
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(
                                border: const Border(
                                  bottom: BorderSide(color: Colors.black),
                                  left: BorderSide(color: Colors.black),
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      final index = value.toInt();
                                      if (index < aggregatedData.keys.length) {
                                        return Text(
                                          aggregatedData.keys.toList()[index],
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              barGroups: barGroups,
                            )

                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
