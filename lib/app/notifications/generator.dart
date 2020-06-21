import 'package:flutter/material.dart';

import 'package:genpass/domain/generator.dart';

abstract class GeneratorNotification extends Notification {
  const GeneratorNotification();
}

class GeneratorAddNotification extends GeneratorNotification {
  const GeneratorAddNotification();
}

class GeneratorRemoveNotification extends GeneratorNotification {
  const GeneratorRemoveNotification(this.index);
  
  final int index;
}

class GeneratorUpdateNotification extends GeneratorNotification {
  const GeneratorUpdateNotification(this.generator);

  final Generator generator;
}
