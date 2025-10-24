// lib/ui/console_utils.dart

import 'dart:io';

// UI Layer Utility - For colors and input
class ConsoleUtils {
  // ANSI Color Codes
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String bold = '\x1B[1m';

  static void printHeader(String title) {
    print('\n$bold$magenta============================================$reset');
    print('$bold$magenta         $title         $reset');
    print('$bold$magenta============================================$reset');
  }

  static void printSuccess(String message) {
    print('$green\n✓ $message$reset');
  }

  static void printError(String message) {
    print('$red\n✗ $message$reset');
  }

  static void printInfo(String message) {
    print('$cyan\nℹ $message$reset');
  }

  static String readInput(String prompt, {bool allowEmpty = false}) {
    String? input;
    while (input == null || (!allowEmpty && input.isEmpty)) {
      stdout.write('$yellow$prompt$reset');
      input = stdin.readLineSync();

      if (!allowEmpty && (input == null || input.isEmpty)) {
        printError('Input cannot be empty. Please try again.');
      }
    }
    // Return the input, which could be empty if allowEmpty was true
    return input ?? '';
  }

  static int? readInt(String prompt) {
    // We pass allowEmpty: false (the default) to ensure we get a number
    String input = readInput(prompt, allowEmpty: false);
    try {
      return int.parse(input);
    } catch (e) {
      printError('Invalid number. Please enter digits only.');
      return null;
    }
  }

  static void clearScreen() {
    if (Platform.isWindows) {
      stdout.write(Process.runSync("cls", [], runInShell: true).stdout);
    } else {
      stdout.write(Process.runSync("clear", [], runInShell: true).stdout);
    }
  }

  static void waitForKey() {
    stdout.write('\n$bold... Press Enter to continue ...$reset');
    stdin.readLineSync();
  }

  static String pad(String text, int width, {bool alignRight = false}) {
    if (text.length > width) {
      // Truncate if too long, adding '…'
      return text.substring(0, width - 1) + '…';
    }
    if (alignRight) {
      return text.padLeft(width);
    }
    return text.padRight(width);
  }
}