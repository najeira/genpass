import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/notifications/generator.dart';
import 'package:genpass/app/pages/setting.dart';
import 'package:genpass/app/widgets/result_row.dart';
import 'package:genpass/domain/gen_pass_data.dart';
import 'package:genpass/domain/generator.dart';
import 'package:genpass/domain/settings.dart';

class GeneratorSection extends StatelessWidget {
  const GeneratorSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("GeneratorSection.build");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _GeneratorTitle(),
        const Padding(
          padding: EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
          child: _PasswordResultRow(),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 0.0),
          child: _PinResultRow(),
        ),
        const Divider(),
      ],
    );
  }
}

class _PasswordResultRow extends StatelessWidget {
  const _PasswordResultRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_PasswordResultRow.build");
    return ProxyProvider<Generator, String>(
      update: (BuildContext context, Generator value, String previous) {
        log.fine("_PasswordResultRow.update");
        return value.password;
      },
      child: ResultRowController.provider(
        child: ResultRow(
          title: kTitlePassword,
          icon: kIconPassword,
        ),
      ),
    );
  }
}

class _PinResultRow extends StatelessWidget {
  const _PinResultRow({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_PinResultRow.build");
    return ProxyProvider<Generator, String>(
      update: (BuildContext context, Generator value, String previous) {
        log.fine("_PinResultRow.update");
        return value.pin;
      },
      child: ResultRowController.provider(
        child: ResultRow(
          title: kTitlePin,
          icon: kIconPin,
        ),
      ),
    );
  }
}

class _GeneratorTitle extends StatelessWidget {
  const _GeneratorTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log.fine("_GeneratorTitle.build");
    final int number = context.watch<int>() ?? 0;
    final ThemeData themeData = Theme.of(context);
    final double fontSize = themeData.textTheme.bodyText2.fontSize;
    final BoxConstraints iconButtonConstraints = const BoxConstraints(
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
            icon: Icon(Icons.settings),
            iconSize: fontSize,
            color: themeData.colorScheme.secondaryVariant,
            padding: const EdgeInsets.all(0.0),
            constraints: iconButtonConstraints,
            onPressed: () => _onSettingsPressed(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            iconSize: fontSize,
            color: themeData.colorScheme.secondaryVariant,
            padding: const EdgeInsets.all(0.0),
            constraints: iconButtonConstraints,
            onPressed: () {
              final GeneratorRemoveNotification notification = GeneratorRemoveNotification(number);
              notification.dispatch(context);
            },
          ),
        ],
      ),
    );
  }

  void _onSettingsPressed(BuildContext context) {
    final Generator generator = context.read<Generator>();
    assert(generator != null);

    Navigator.of(context)?.push<Setting>(
      MaterialPageRoute<Setting>(
        builder: (BuildContext context) {
          return SettingPage(setting: generator.setting);
        },
      ),
    )?.then((Setting setting) async {
      if (setting == null) {
        return;
      }
      generator.setting = setting;

      final GeneratorUpdateNotification notification = GeneratorUpdateNotification(generator);
      notification.dispatch(context);
    });
  }
}
