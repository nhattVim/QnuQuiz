import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/analytics/score_distribution_model.dart';
import 'package:frontend/widgets/analytics/async_data_builder.dart';

class ScoreDistributionTab extends StatefulWidget {
  final Future<List<ScoreDistribution>> future;
  const ScoreDistributionTab({super.key, required this.future});

  @override
  State<ScoreDistributionTab> createState() => _ScoreDistributionTabState();
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ScoreDistributionTabState extends State<ScoreDistributionTab> {
  ScoreDistribution? _selectedDist;

  @override
  Widget build(BuildContext context) {
    return AsyncDataBuilder<List<ScoreDistribution>>(
      future: widget.future,
      builder: (data) {
        final dist = _selectedDist ?? data.first;
        final theme = Theme.of(context);

        return Column(
          children: [
            if (data.length > 1)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<ScoreDistribution>(
                  initialValue: dist,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: data
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.title)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedDist = val),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(dist.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 30),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            _buildPieSection(
                              dist.excellentCount,
                              'Giỏi',
                              Colors.green,
                            ),
                            _buildPieSection(
                              dist.goodCount,
                              'Khá',
                              Colors.blue,
                            ),
                            _buildPieSection(
                              dist.averageCount,
                              'TB',
                              Colors.orange,
                            ),
                            _buildPieSection(
                              dist.failCount,
                              'Yếu',
                              theme.colorScheme.error,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        const _LegendItem(color: Colors.green, text: 'Giỏi'),
                        const _LegendItem(color: Colors.blue, text: 'Khá'),
                        const _LegendItem(
                          color: Colors.orange,
                          text: 'Trung bình',
                        ),
                        _LegendItem(
                          color: theme.colorScheme.error,
                          text: 'Trượt',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  PieChartSectionData _buildPieSection(int value, String title, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '$value',
      radius: 80,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
