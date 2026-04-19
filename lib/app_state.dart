import 'dart:math';

/// Shared mutable state used by painters and legacy UI paths.
Random rnd = Random();
int seed = DateTime.now().millisecond;
double aspectRatio = 2 / 3;

bool showDelete = false;
