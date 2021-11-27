import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/pages/setting.dart';
import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/result_row.dart';

class GeneratorSection extends StatelessWidget {
  const GeneratorSection._({
    Key? key,
  }) : super(key: key);

  static Widget withIndex(BuildContext context, int index) {
    return ProviderScope(
      overrides: [
        selectedSettingIndexProvider.overrideWithValue(index),
      ],
      child: const GeneratorSection._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    log.fine("GeneratorSection.build");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        _GeneratorTitle(),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
          child: _PasswordResultRow(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
          child: _PinResultRow(),
        ),
        Divider(),
      ],
    );
  }
}

class _PasswordResultRow extends ConsumerWidget {
  const _PasswordResultRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_PasswordResultRow.build");
    final index = ref.watch(selectedSettingIndexProvider);
    final value = ref.watch(resultPasswordProvider(index));
    return ResultRow(
      title: kTitlePassword,
      icon: kIconPassword,
      value: value,
      onVisiblityChanged: (value) {
        final ctrl = ref.watch(passwordVisibilityProvider(index).notifier);
        ctrl.state = value;
      },
    );
  }
}

class _PinResultRow extends ConsumerWidget {
  const _PinResultRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_PinResultRow.build");
    final index = ref.watch(selectedSettingIndexProvider);
    final value = ref.watch(resultPinProvider(index));
    return ResultRow(
      title: kTitlePin,
      icon: kIconPin,
      value: value,
      onVisiblityChanged: (value) {
        final ctrl = ref.watch(pinVisibilityProvider(index).notifier);
        ctrl.state = value;
      },
    );
  }
}

class _GeneratorTitle extends ConsumerWidget {
  const _GeneratorTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_GeneratorTitle.build");
    final number = ref.watch(selectedSettingIndexProvider);
    final themeData = Theme.of(context);
    final fontSize = themeData.textTheme.bodyText2!.fontSize!;
    const iconButtonConstraints = BoxConstraints(
      minWidth: 32.0,
      minHeight: 24.0,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
      child: Row(
        children: [
          Text(
            "Generator ${number + 1}",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.settings),
            iconSize: fontSize,
            color: themeData.colorScheme.secondaryVariant,
            padding: const EdgeInsets.all(0.0),
            constraints: iconButtonConstraints,
            onPressed: () => SettingPage.push(context, number),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            iconSize: fontSize,
            color: themeData.colorScheme.secondaryVariant,
            padding: const EdgeInsets.all(0.0),
            constraints: iconButtonConstraints,
            onPressed: () {
              final ctrl = ref.read(settingListProvider.notifier);
              ctrl.removeAt(number);
              ctrl.save();
            },
          ),
        ],
      ),
    );
  }
}
