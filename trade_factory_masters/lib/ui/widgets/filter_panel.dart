import 'package:flutter/material.dart';
import '../../domain/entities/conveyor_tile.dart';
import '../../config/game_config.dart';

/// Filter configuration panel - modal dialog for setting up filters
/// Allows player to configure which items pass through conveyor tiles
class FilterPanel extends StatefulWidget {
  /// Current filter configuration
  final ConveyorFilter currentFilter;

  /// Available resource IDs to filter
  final List<String> availableResources;

  /// Callback when filter is applied
  final Function(ConveyorFilter) onApply;

  /// Callback when filter is cancelled
  final VoidCallback onCancel;

  const FilterPanel({
    Key? key,
    required this.currentFilter,
    required this.availableResources,
    required this.onApply,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late FilterMode _selectedMode;
  late Set<String> _selectedResources;
  late String? _selectedSingleResource;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.currentFilter.mode;
    _selectedResources = Set.from(widget.currentFilter.resourceIds);
    _selectedSingleResource = widget.currentFilter.singleResourceId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure Filter'),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode selection
              const Text('Filter Mode', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildModeSelector(),
              const SizedBox(height: 24),

              // Resource selection (only for list modes)
              if (_selectedMode != FilterMode.allowAll)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMode == FilterMode.single
                          ? 'Select Resource'
                          : 'Select Resources (max 3)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedMode == FilterMode.single)
                      _buildSingleResourcePicker()
                    else
                      _buildMultiResourcePicker(),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isValidConfiguration()
              ? () {
                  final newFilter = _buildFilter();
                  widget.onApply(newFilter);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  /// Build mode selection radio buttons
  Widget _buildModeSelector() {
    return Column(
      children: [
        _buildModeRadio(
          FilterMode.allowAll,
          'Allow All',
          'All items pass through',
        ),
        _buildModeRadio(
          FilterMode.whitelist,
          'Whitelist',
          'Only selected items pass',
        ),
        _buildModeRadio(
          FilterMode.blacklist,
          'Blacklist',
          'Selected items blocked',
        ),
        _buildModeRadio(
          FilterMode.single,
          'Single Item',
          'Only one type passes',
        ),
      ],
    );
  }

  /// Build a single mode radio button
  Widget _buildModeRadio(
    FilterMode mode,
    String title,
    String subtitle,
  ) {
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Radio<FilterMode>(
              value: mode,
              groupValue: _selectedMode,
              onChanged: (value) => setState(() => _selectedMode = value ?? mode),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build single resource picker dropdown
  Widget _buildSingleResourcePicker() {
    return DropdownButton<String>(
      isExpanded: true,
      value: _selectedSingleResource,
      hint: const Text('Choose resource...'),
      items: widget.availableResources
          .map((resource) => DropdownMenuItem(
                value: resource,
                child: Text(resource),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedSingleResource = value),
    );
  }

  /// Build multi-resource picker (checkboxes with max 3)
  Widget _buildMultiResourcePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.availableResources
          .map((resource) => _buildResourceCheckbox(resource))
          .toList(),
    );
  }

  /// Build single resource checkbox
  Widget _buildResourceCheckbox(String resourceId) {
    final isSelected = _selectedResources.contains(resourceId);
    final isAtMax = _selectedResources.length >= ConveyorFilter.maxListItems;
    final canToggle = isSelected || !isAtMax;

    return CheckboxListTile(
      enabled: canToggle,
      value: isSelected,
      title: Text(resourceId),
      onChanged: canToggle
          ? (value) {
              setState(() {
                if (value == true) {
                  _selectedResources.add(resourceId);
                } else {
                  _selectedResources.remove(resourceId);
                }
              });
            }
          : null,
    );
  }

  /// Build new filter from current selections
  ConveyorFilter _buildFilter() {
    switch (_selectedMode) {
      case FilterMode.allowAll:
        return const ConveyorFilter();
      case FilterMode.whitelist:
        return ConveyorFilter.whitelist(_selectedResources.toList());
      case FilterMode.blacklist:
        return ConveyorFilter.blacklist(_selectedResources.toList());
      case FilterMode.single:
        return ConveyorFilter.single(_selectedSingleResource ?? '');
    }
  }

  /// Check if current configuration is valid
  bool _isValidConfiguration() {
    switch (_selectedMode) {
      case FilterMode.allowAll:
        return true;
      case FilterMode.whitelist:
      case FilterMode.blacklist:
        return _selectedResources.isNotEmpty &&
            _selectedResources.length <= ConveyorFilter.maxListItems;
      case FilterMode.single:
        return _selectedSingleResource != null &&
            _selectedSingleResource!.isNotEmpty;
    }
  }
}
