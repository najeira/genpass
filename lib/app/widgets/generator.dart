import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/pages/setting.dart';
import 'package:genpass/app/providers.dart';
import 'package:genpass/app/widgets/result_row.dart';

class GeneratorSection extends StatelessWidget {
  const GeneratorSection._({
    super.key,
  });

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
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 8.0),
        _GeneratorTitle(),
        _PasswordResultRow(),
        SizedBox(height: 8.0),
        _PinResultRow(),
        SizedBox(height: 24.0),
        Divider(height: 1.0),
      ],
    );
  }
}

class _PasswordResultRow extends ConsumerWidget {
  const _PasswordResultRow({
    super.key,
  });

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
    super.key,
  });

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
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log.fine("_GeneratorTitle.build");
    final themeData = Theme.of(context);
    final number = ref.watch(selectedSettingIndexProvider);
    return Row(
      children: [
        Text(
          "Generator ${number + 1}",
          style: themeData.textTheme.titleSmall,
        ),
        const SizedBox(width: 8.0),
        _IconButton(
          iconData: Icons.settings,
          onPressed: () {
            SettingPage.push(context, number);
          },
        ),
        _IconButton(
          iconData: Icons.delete,
          onPressed: () async {
            final ctrl = ref.read(settingListProvider.notifier);
            ctrl.removeAt(number);
          },
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    super.key,
    required this.iconData,
    this.onPressed,
  });

  final IconData iconData;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return IconButton(
      icon: Icon(iconData),
      color: themeData.colorScheme.tertiary,
      padding: const EdgeInsets.all(0.0),
      onPressed: onPressed,
    );
  }
}
