import 'package:flutter/material.dart';

class JsonViewer extends StatelessWidget {
  final dynamic data;
  final int indent;
  final bool isRoot;

  const JsonViewer(
      this.data, {
        super.key,
        this.indent = 0,
        this.isRoot = true,
      });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Text('null', style: TextStyle(fontFamily: 'monospace'));
    }

    if (isRoot) {
      return SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(),
            ),
          ),
        ),
      );
    }

    return _buildContent();
  }

  Widget _buildContent() {
    if (data is Map) {
      return _buildMap(data as Map);
    } else if (data is List) {
      return _buildList(data as List);
    } else {
      // Handle non-primitive types
      if (data.toString().startsWith('Instance of')) {
        // If it's a model class, try to get its JSON representation
        try {
          if (data.toJson != null) {
            final jsonData = data.toJson();
            return JsonViewer(
              jsonData,
              indent: indent,
              isRoot: false,
            );
          }
        } catch (_) {}
      }
      return Text(
        data.toString(),
        style: const TextStyle(fontFamily: 'monospace'),
      );
    }
  }

  Widget _buildMap(Map map) {
    final entries = map.entries.toList();
    if (entries.isEmpty) {
      return const Text('{}', style: TextStyle(fontFamily: 'monospace'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('{', style: TextStyle(fontFamily: 'monospace')),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map((entry) {
              return _buildJsonItem(entry.key.toString(), entry.value);
            }).toList(),
          ),
        ),
        const Text('}', style: TextStyle(fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildList(List list) {
    if (list.isEmpty) {
      return const Text('[]', style: TextStyle(fontFamily: 'monospace'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('[', style: TextStyle(fontFamily: 'monospace')),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: list.map((item) {
              return JsonViewer(
                item,
                indent: indent + 1,
                isRoot: false,
              );
            }).toList(),
          ),
        ),
        const Text(']', style: TextStyle(fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildJsonItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          value is Map || value is List
              ? Text(
            '$key:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          )
              : Text(
            '$key: ${value?.toString() ?? 'null'}',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          if (value is Map || value is List)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: JsonViewer(
                value,
                indent: indent + 1,
                isRoot: false,
              ),
            ),
        ],
      ),
    );
  }
}