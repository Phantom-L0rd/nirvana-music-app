import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirvana_desktop/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              const Divider(),

              // Local Files Folder
              FileSelectorWidget(),

              const Divider(),

              // Accent Color
              AccentColorPickerTile(),

              // Storage Settings
              CacheSettingWidget(),

              DownloadSettingWidget(),

              CrossfadeSettingWidget(),

              // Equalizer
              EqualizerWidget(),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('App Version: 1.0.0'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CacheSettingWidget extends StatelessWidget {
  const CacheSettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8, 16.0, 8),
          child: Row(
            children: [
              Icon(Icons.cached),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cache:", style: TextStyle(fontSize: 16)),
                  Text(
                    "Used: 200MB",
                    style: TextStyle(color: Colors.grey),
                  ), // TODO: add the actual cache sizez
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: logic of clearing cache
                },
                child: Text("Clear Cache"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DownloadSettingWidget extends StatefulWidget {
  const DownloadSettingWidget({super.key});

  @override
  State<DownloadSettingWidget> createState() => _DownloadSettingWidgetState();
}

class _DownloadSettingWidgetState extends State<DownloadSettingWidget> {
  bool isEnabled = false;
  double downloadSize = 4147.39; // TODO: link the actual downloaded file sizes

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8, 16.0, 8),
          child: Row(
            children: [
              Icon(Icons.download),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Downloads:", style: TextStyle(fontSize: 16)),
                  Text(
                    "Used: ${downloadSize.round()}MB",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    downloadSize = 0;
                    isEnabled = false;
                  }); // TODO: logic of clearing downloads
                },
                child: Text("Clear Downloads"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CrossfadeSettingWidget extends StatefulWidget {
  const CrossfadeSettingWidget({super.key});

  @override
  State<CrossfadeSettingWidget> createState() => _CrossfadeSettingWidgetState();
}

class _CrossfadeSettingWidgetState extends State<CrossfadeSettingWidget> {
  bool isEnabled = false;
  double crossfadeDuration = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.compare_arrows),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Crossfade Duration:", style: TextStyle(fontSize: 16)),
                  Text(
                    "Time: ${crossfadeDuration.round()} sec",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Slider(
                value: crossfadeDuration,
                onChanged: isEnabled
                    ? (val) {
                        setState(() => crossfadeDuration = val);
                      }
                    : null,
                min: 0,
                max: 12,
                divisions: 12,
                label: "${crossfadeDuration.round()}s",
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Colors.grey,
              ),
              const Spacer(),
              Switch(
                value: isEnabled,
                onChanged: (val) {
                  setState(() => isEnabled = val);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class FileSelectorWidget extends StatefulWidget {
  const FileSelectorWidget({super.key});

  @override
  State<FileSelectorWidget> createState() => _FileSelectorWidgetState();
}

class _FileSelectorWidgetState extends State<FileSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final folders = ref.watch(localFoldersProvider).localFolders;
        bool isEnabled = folders.isNotEmpty;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8, 16.0, 0),
              child: Row(
                children: [
                  const Icon(Icons.folder),
                  const SizedBox(width: 8),
                  const Text('Local Files:', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final String? path = await getDirectoryPath();
                      if (path != null) {
                        ref.read(localFoldersProvider).addFolder(path);
                      }
                    },
                    child: const Text('Add Folder'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: isEnabled
                        ? () {
                            ref.read(localFoldersProvider).rescanFolders();
                          }
                        : null,
                    child: const Text('Scan Files'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(36, 0, 36, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(folders.length, (index) {
                  return Row(
                    children: [
                      Text(
                        folders[index],
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () {
                          ref
                              .read(localFoldersProvider)
                              .removeFolder(folders[index]);
                        },
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EqualizerWidget extends StatefulWidget {
  const EqualizerWidget({super.key});

  @override
  State<EqualizerWidget> createState() => _EqualizerWidgetState();
}

class _EqualizerWidgetState extends State<EqualizerWidget> {
  bool isEnabled = false;

  final List<double> gains = [6, 5, 3, 1, 0, 0];
  final List<String> frequencies = [
    '60Hz',
    '150Hz',
    '400Hz',
    '1KHz',
    '2.4KHz',
    '15KHz',
  ];
  final List<String> presets = [
    'Flat',
    'Bass booster',
    'Treble booster',
    'Rock',
    'Pop',
  ];
  String selectedPreset = 'Bass booster';

  void reset() {
    setState(() {
      for (int i = 0; i < gains.length; i++) {
        gains[i] = 0;
      }
      selectedPreset = 'Flat';
    });
    saveEqualizerSettings();
  }

  @override
  void initState() {
    super.initState();
    loadEqualizerSettings();
  }

  Future<void> saveEqualizerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eq_enabled', isEnabled);
    await prefs.setString('eq_preset', selectedPreset);
    await prefs.setString('eq_gains', jsonEncode(gains));
  }

  Future<void> loadEqualizerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isEnabled = prefs.getBool('eq_enabled') ?? false;
      selectedPreset = prefs.getString('eq_preset') ?? 'Bass booster';

      final gainsString = prefs.getString('eq_gains');
      if (gainsString != null) {
        List<dynamic> loaded = jsonDecode(gainsString);
        for (int i = 0; i < gains.length && i < loaded.length; i++) {
          gains[i] = loaded[i].toDouble();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top: Title and toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.equalizer),
                const Text('Equalizer', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                  value: isEnabled,
                  onChanged: (val) {
                    setState(() => isEnabled = val);
                    saveEqualizerSettings();
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Preset dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Presets'),
                DropdownButton<String>(
                  borderRadius: BorderRadius.circular(6),
                  padding: EdgeInsets.all(6),

                  // focusColor: Theme.of(context).cardColor,
                  value: selectedPreset,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedPreset = val;
                        // optionally: update gains for each preset
                      });
                      saveEqualizerSettings();
                    }
                  },
                  items: presets.map((String preset) {
                    return DropdownMenuItem<String>(
                      value: preset,
                      child: Text(preset),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // EQ Sliders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(gains.length, (index) {
                return Column(
                  children: [
                    RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        value: gains[index],
                        onChanged: isEnabled
                            ? (val) {
                                setState(() => gains[index] = val);
                                saveEqualizerSettings();
                              }
                            : null,
                        min: -12,
                        max: 12,
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      frequencies[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 12),

            // Reset button
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                ),
                child: const Text('Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccentColorPickerTile extends StatelessWidget {
  const AccentColorPickerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text('Accent Color:'),
          subtitle: const Text('Choose a theme color'),

          onTap: () async {
            final Color? newColor = await showDialog<Color>(
              context: context,
              builder: (context) {
                final currentColor = Theme.of(context).colorScheme.primary;
                Color selectedColor = currentColor;
                return AlertDialog(
                  title: const Text('Pick an Accent Color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        selectedColor = color;
                      },
                    ),
                    // ColorPicker(
                    //   pickerColor: selectedColor,
                    //   onColorChanged: (color) {
                    //     selectedColor = color;
                    //   },
                    //   enableAlpha: true, // allows transparency (A)
                    //   displayThumbColor: true,
                    //   labelTypes: const [ColorLabelType.rgb],
                    //   portraitOnly: true,
                    // ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      child: const Text('Select'),
                      onPressed: () => Navigator.of(context).pop(selectedColor),
                    ),
                  ],
                );
              },
            );

            if (newColor != null) {
              ref.read(themeNotifierProvider.notifier).setSeedColor(newColor);
            }
          },
        );
      },
    );
  }
}
