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

  // Create an instance of FirestoreService
  Future<Map<String, int>> getData() async {
    final data = await firestoreService.fetchOrderData();
    return data;
  }

  // Function to generate a list of colors for pie chart
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

    // Repeat the colors if there are more products than available colors
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
            SizedBox(height: 16),
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
                      color: color, // Assign color
                      title: '$productName\n$quantitySold', // Show name and quantity
                      radius: MediaQuery.of(context).size.width * 0.25, // Dynamic radius based on screen width
                      titleStyle: TextStyle(
                        fontSize: 14, // Adjust font size for labels
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4, // Adjust line height for better spacing
                      ),
                    );
                  }).toList();

                  return PieChart(
                    PieChartData(
                      sections: pieSections,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2, // Space between sections
                      centerSpaceRadius: MediaQuery.of(context).size.width * 0.25,

                    ),
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
