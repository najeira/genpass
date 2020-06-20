import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:genpass/app/gloabls.dart';
import 'package:genpass/app/widgets/result_row.dart';
import 'package:genpass/domain/gen_pass_data.dart';
import 'package:genpass/domain/generator.dart';

class GeneratorSection extends StatelessWidget {
  const GeneratorSection({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
        return value.password;
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
