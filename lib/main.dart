import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111411),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB7F36B),
          surface: Color(0xFF1B201C),
          onSurface: Color(0xFFF3F5F0),
        ),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _accent = Color(0xFFB7F36B);
  static const _keyColor = Color(0xFF252B26);
  static const _operatorColor = Color(0xFF394238);
  String _expression = '';
  String _preview = '';
  String? _error;
  final List<String> _history = [];

  void _append(String value) {
    setState(() {
      if (_error != null) {
        _expression = '';
        _error = null;
      }
      if (value == '.') {
        final current = _expression.split(RegExp(r'[+\-*/%]')).last;
        if (current.contains('.')) return;
        if (current.isEmpty) value = '0.';
      } else if ('+-*/'.contains(value)) {
        if (_expression.isEmpty && value != '-') return;
        if (_expression.isNotEmpty && '+-*/'.contains(_expression[_expression.length - 1])) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '%' &&
          (_expression.isEmpty || '+-*/.'.contains(_expression[_expression.length - 1]))) {
        return;
      }
      _expression += value;
      _updatePreview();
    });
  }

  void _clear() => setState(() {
        _expression = '';
        _preview = '';
        _error = null;
      });

  void _backspace() {
    setState(() {
      if (_error != null) {
        _expression = '';
        _preview = '';
        _error = null;
      } else {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        _updatePreview();
      }
    });
  }

  void _updatePreview() {
    if (_expression.isEmpty || '+-*/'.contains(_expression[_expression.length - 1])) {
      _preview = '';
      return;
    }
    try {
      _preview = _formatNumber(_ExpressionParser(_expression).parse());
    } on FormatException {
      _preview = '';
    } on _DivisionByZero {
      _preview = '';
    }
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    final calculation = _expression;
    try {
      final result = _formatNumber(_ExpressionParser(calculation).parse());
      setState(() {
        _history.insert(0, '${_display(calculation)} = $result');
        _expression = result;
        _preview = '';
        _error = null;
      });
    } on _DivisionByZero {
      setState(() {
        _error = 'Tidak bisa bagi 0';
        _preview = '';
      });
    } on FormatException {
      setState(() {
        _error = 'Input tidak valid';
        _preview = '';
      });
    }
  }

  String _formatNumber(double value) {
    if (!value.isFinite) throw const FormatException('Hasil tidak valid');
    if (value == value.roundToDouble() && value.abs() < 1e15) return value.toInt().toString();
    final text = value.toStringAsPrecision(12);
    return text.contains('e') ? text : text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _display(String value) => value.replaceAll('*', '×').replaceAll('/', '÷');

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B201C),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: _HistoryPanel(history: _history, onClear: () => setState(_history.clear)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final calculator = _buildCalculator(context);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: constraints.maxWidth >= 760
                      ? Row(children: [
                          Expanded(flex: 6, child: calculator),
                          const VerticalDivider(width: 1, color: Color(0xFF303730)),
                          Expanded(
                            flex: 3,
                            child: _HistoryPanel(history: _history, onClear: () => setState(_history.clear)),
                          ),
                        ])
                      : calculator,
                ),
              );
            },
          ),
        ),
      );

  Widget _buildCalculator(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(children: [
          Row(children: [
            const Text('KALKULATOR', style: TextStyle(color: Color(0xFF9AA398), fontSize: 13,
                fontWeight: FontWeight.w700, letterSpacing: 1.8)),
            const Spacer(),
            if (MediaQuery.sizeOf(context).width < 760)
              IconButton(tooltip: 'Riwayat', onPressed: _showHistory, icon: const Icon(Icons.history_rounded)),
          ]),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                reverse: true,
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_error ?? (_expression.isEmpty ? '0' : _display(_expression)),
                      key: const Key('expression'), textAlign: TextAlign.right,
                      style: TextStyle(color: _error == null ? const Color(0xFFF3F5F0) : const Color(0xFFFF887C),
                          fontSize: _error == null ? 42 : 24)),
                  const SizedBox(height: 8),
                  Text(_preview.isEmpty ? ' ' : '= $_preview', key: const Key('preview'),
                      style: const TextStyle(color: Color(0xFF9AA398), fontSize: 20)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            flex: 5,
            child: Column(children: [
              _row([
                _Key('C', _clear, _operatorColor, _accent),
                _Key('⌫', _backspace, _operatorColor, _accent, 'Hapus satu karakter'),
                _Key('%', () => _append('%'), _operatorColor, _accent),
                _Key('÷', () => _append('/'), _operatorColor, _accent),
              ]),
              _row([
                for (final digit in ['7', '8', '9']) _Key(digit, () => _append(digit)),
                _Key('×', () => _append('*'), _operatorColor, _accent),
              ]),
              _row([
                for (final digit in ['4', '5', '6']) _Key(digit, () => _append(digit)),
                _Key('-', () => _append('-'), _operatorColor, _accent),
              ]),
              _row([
                for (final digit in ['1', '2', '3']) _Key(digit, () => _append(digit)),
                _Key('+', () => _append('+'), _operatorColor, _accent),
              ]),
              _row([
                _Key('±', _toggleSign),
                _Key('0', () => _append('0')),
                _Key('.', () => _append('.')),
                _Key('=', _calculate, _accent, const Color(0xFF17200F)),
              ]),
            ]),
          ),
        ]),
      );

  void _toggleSign() {
    setState(() {
      final match = RegExp(r'((?:\d+\.?\d*|\.\d+))$').firstMatch(_expression);
      if (match == null) {
        if (_expression.isEmpty) _expression = '-';
        return;
      }
      final start = match.start;
      final signIndex = start - 1;
      final unary = signIndex >= 0 && _expression[signIndex] == '-' &&
          (signIndex == 0 || '+-*/'.contains(_expression[signIndex - 1]));
      _expression = unary
          ? _expression.substring(0, signIndex) + _expression.substring(start)
          : '${_expression.substring(0, start)}-${_expression.substring(start)}';
      _updatePreview();
    });
  }

  Widget _row(List<_Key> keys) => Expanded(
        child: Row(children: [
          for (var index = 0; index < keys.length; index++) ...[
            if (index > 0) const SizedBox(width: 10),
            Expanded(child: _CalculatorButton(keySpec: keys[index])),
          ],
        ]),
      );
}

class _Key {
    const _Key(this.label, this.action, [this.color = _CalculatorPageState._keyColor,
      this.foreground = const Color(0xFFF3F5F0), this.semanticLabel]);
  final String label;
  final VoidCallback action;
  final Color color;
  final Color foreground;
  final String? semanticLabel;
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({required this.keySpec});
  final _Key keySpec;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox.expand(
          child: Semantics(
            label: keySpec.semanticLabel ?? keySpec.label,
            button: true,
            child: Material(
              color: keySpec.color,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: keySpec.action,
                child: Center(child: Text(keySpec.label, style: TextStyle(color: keySpec.foreground,
                    fontSize: 25, fontWeight: FontWeight.w600))),
              ),
            ),
          ),
        ),
      );
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.history, required this.onClear});
  final List<String> history;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Riwayat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
            if (history.isNotEmpty)
              IconButton(tooltip: 'Hapus riwayat', onPressed: onClear, icon: const Icon(Icons.delete_outline_rounded)),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text('Belum ada perhitungan', style: TextStyle(color: Color(0xFF9AA398))))
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const Divider(color: Color(0xFF303730), height: 24),
                    itemBuilder: (context, index) => Text(history[index], textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 17, color: Color(0xFFD8DED5))),
                  ),
          ),
        ]),
      );
}

class _DivisionByZero implements Exception {
  const _DivisionByZero();
}

class _ExpressionParser {
  _ExpressionParser(this.source);
  final String source;
  int _position = 0;

  double parse() {
    final result = _expression();
    if (_position != source.length || !result.isFinite) throw const FormatException('Input tidak valid');
    return result;
  }

  double _expression() {
    var value = _term();
    while (_match('+') || _match('-')) {
      final operator = source[_position - 1];
      final right = _term();
      value = operator == '+' ? value + right : value - right;
    }
    return value;
  }

  double _term() {
    var value = _unary();
    while (_match('*') || _match('/')) {
      final operator = source[_position - 1];
      final right = _unary();
      if (operator == '/' && right == 0) throw const _DivisionByZero();
      value = operator == '*' ? value * right : value / right;
    }
    return value;
  }

  double _unary() {
    if (_match('+')) return _unary();
    if (_match('-')) return -_unary();
    var value = _number();
    while (_match('%')) {
      value /= 100;
    }
    return value;
  }

  double _number() {
    final start = _position;
    var hasDigit = false;
    var hasDecimal = false;
    while (_position < source.length) {
      final character = source[_position];
      final codeUnit = character.codeUnitAt(0);
      if (codeUnit >= 48 && codeUnit <= 57) {
        hasDigit = true;
        _position++;
      } else if (character == '.' && !hasDecimal) {
        hasDecimal = true;
        _position++;
      } else {
        break;
      }
    }
    if (!hasDigit) throw const FormatException('Angka tidak valid');
    final value = double.tryParse(source.substring(start, _position));
    if (value == null) throw const FormatException('Angka tidak valid');
    return value;
  }

  bool _match(String character) {
    if (_position >= source.length || source[_position] != character) return false;
    _position++;
    return true;
  }
}
