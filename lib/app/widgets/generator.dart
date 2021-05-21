import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/notifications/generator.dart';
import 'package:genpass/app/pages/setting.dart';
import 'package:genpass/app/widgets/result_row.dart';
import 'package:genpass/domain/generator.dart';
import 'package:genpass/domain/settings.dart';

class GeneratorSection extends StatelessWidget {
  const GeneratorSection({
    Key? key,
  }) : super(key: key);

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

class _PasswordResultRow extends StatelessWidget {
  const _PasswordResultRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_PasswordResultRow.build");
    return ProxyProvider<Generator, String>(
      update: (BuildContext context, Generator value, String? previous) {
        log.fine("_PasswordResultRow.update");
        return value.password;
      },
      child: ResultRowController.provider(
        child: const ResultRow(
          title: kTitlePassword,
          icon: kIconPassword,
        ),
      ),
    );
  }
}

class _PinResultRow extends StatelessWidget {
  const _PinResultRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_PinResultRow.build");
    return ProxyProvider<Generator, String>(
      update: (BuildContext context, Generator value, String? previous) {
        log.fine("_PinResultRow.update");
        return value.pin;
      },
      child: ResultRowController.provider(
        child: const ResultRow(
          title: kTitlePin,
          icon: kIconPin,
        ),
      ),
    );
  }
}

class _GeneratorTitle extends StatelessWidget {
  const _GeneratorTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_GeneratorTitle.build");
    final number = context.watch<int>();
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
            onPressed: () => _onSettingsPressed(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            iconSize: fontSize,
            color: themeData.colorScheme.secondaryVariant,
            padding: const EdgeInsets.all(0.0),
            constraints: iconButtonConstraints,
            onPressed: () {
              final notification = GeneratorRemoveNotification(number);
              notification.dispatch(context);
            },
          ),
        ],
      ),
    );
  }

  void _onSettingsPressed(BuildContext context) {
    final generator = context.read<Generator>();

    Navigator.maybeOf(context)?.push<Setting>(
      MaterialPageRoute<Setting>(
        builder: (BuildContext context) {
          return SettingPage(setting: generator.setting);
        },
      ),
    ).then((Setting? setting) async {
      if (setting == null) {
        return;
      }
      generator.setting = setting;

      final notification = GeneratorUpdateNotification(generator);
      notification.dispatch(context);
    });
  }
}
