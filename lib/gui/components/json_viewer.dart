import 'package:flutter/material.dart';

class JsonViewer extends StatelessWidget {
  final Map<String, dynamic> data;
  final int indent;

  const JsonViewer(this.data, {super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((entry) {
              return _buildJsonItem(context, entry.key, entry.value);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildJsonItem(BuildContext context, String key, dynamic value) {
    if (value is Map) {
      final Map<String, dynamic> mapValue = Map<String, dynamic>.from(value);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: JsonViewer(mapValue, indent: indent + 1),
          ),
        ],
      );
    } else if (value is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key: [',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: value.map((item) {
                if (item is Map) {
                  return JsonViewer(Map<String, dynamic>.from(item),
                      indent: indent + 1);
                }
                return Text(item.toString());
              }).toList(),
            ),
          ),
          const Text(']'),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '$key: ${value?.toString() ?? 'null'}',
        style: const TextStyle(
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}