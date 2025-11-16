import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
  });
}

void main() {
  setupLogger();
  runApp(const MyApp());
}

final log = Logger('DualCounterApp');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    log.info('Aplicação iniciada.');

    return MaterialApp(
      title: 'Dual Counter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DualCounterPage(title: 'Contadores com Limite e Passo'),
    );
  }
}

class DualCounterPage extends StatefulWidget {
  const DualCounterPage({super.key, required this.title});
  final String title;

  @override
  State<DualCounterPage> createState() => _DualCounterPageState();
}

class _DualCounterPageState extends State<DualCounterPage> {
  int _counter1 = 0;
  int _counter2 = 0;

  int _limitValue = 10;
  final TextEditingController _limitController =
      TextEditingController(text: '10');

  int _stepValue1 = 1;
  int _stepValue2 = 1;
  final TextEditingController _stepController1 =
      TextEditingController(text: '1');
  final TextEditingController _stepController2 =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _stepController1.addListener(() => _updateStepValue(1));
    _stepController2.addListener(() => _updateStepValue(2));
    _limitController.addListener(_updateLimitValue);
    log.info('Página DualCounterPage inicializada com Limite=$_limitValue.');
  }

  @override
  void dispose() {
    _stepController1.dispose();
    _stepController2.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _updateLimitValue() {
    final newLimit = int.tryParse(_limitController.text) ?? 1;

    if (newLimit != _limitValue && newLimit > 0) {
      setState(() {
        _limitValue = newLimit;

        _counter1 = _counter1.clamp(-_limitValue, _limitValue);
        _counter2 = _counter2.clamp(-_limitValue, _limitValue);

        log.config('Limite Global atualizado para ±$_limitValue.');
      });
    }
  }

  void _updateStepValue(int counterId) {
    final controller = counterId == 1 ? _stepController1 : _stepController2;
    final currentStep = counterId == 1 ? _stepValue1 : _stepValue2;

    // Tenta converter o texto para inteiro. Se falhar, usa 0 temporariamente para validação.
    final newStep = int.tryParse(controller.text) ?? 0;

    // Validação principal: O passo não pode ser 0
    if (newStep == 0) {
      // Adiciona o log de WARNING e não altera o estado se for zero
      log.warning(
          'Tentativa de definir o Passo para 0 no Contador $counterId. Valor inválido, mantendo $currentStep.');

      // Opcional: Reverte o campo visualmente para o último valor válido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verifica se o controlador ainda está anexado antes de modificar
        if (controller.text != currentStep.toString()) {
          controller.text = currentStep.toString();
        }
      });
      return;
    }

    // Se o novo passo for válido e diferente do atual, atualiza o estado
    if (newStep != currentStep) {
      setState(() {
        if (counterId == 1) {
          _stepValue1 = newStep;
        } else {
          _stepValue2 = newStep;
        }
        log.info('Passo para o Contador $counterId atualizado para $newStep.');
      });
    }
  }

  void _incrementCounter1() {
    setState(() {
      final nextValue = _counter1 + _stepValue1;

      if (nextValue <= _limitValue) {
        _counter1 = nextValue;
        log.fine('C1: Incrementado por $_stepValue1. Novo valor: $_counter1.');
      } else {
        _counter1 = _limitValue;
        log.warning(
            'C1: Atingiu o limite MÁXIMO $_limitValue. Não é possível incrementar mais.');
      }
    });
  }

  void _decrementCounter1() {
    setState(() {
      final nextValue = _counter1 - _stepValue1;

      if (nextValue >= -_limitValue) {
        _counter1 = nextValue;
        log.fine('C1: Decrementado por $_stepValue1. Novo valor: $_counter1.');
      } else {
        _counter1 = -_limitValue;
        log.warning(
            'C1: Atingiu o limite MÍNIMO -$_limitValue. Não é possível decrementar mais.');
      }
    });
  }

  void _incrementCounter2() {
    setState(() {
      final nextValue = _counter2 + _stepValue2;

      if (nextValue <= _limitValue) {
        _counter2 = nextValue;
        log.fine('C2: Incrementado por $_stepValue2. Novo valor: $_counter2.');
      } else {
        _counter2 = _limitValue;
        log.warning(
            'C2: Atingiu o limite MÁXIMO $_limitValue. Não é possível incrementar mais.');
      }
    });
  }

  void _decrementCounter2() {
    setState(() {
      final nextValue = _counter2 - _stepValue2;

      if (nextValue >= -_limitValue) {
        _counter2 = nextValue;
        log.fine('C2: Decrementado por $_stepValue2. Novo valor: $_counter2.');
      } else {
        _counter2 = -_limitValue;
        log.warning(
            'C2: Atingiu o limite MÍNIMO -$_limitValue. Não é possível decrementar mais.');
      }
    });
  }

  void _resetAllCounters() {
    setState(() {
      _counter1 = 0;
      _counter2 = 0;
      log.info('Todos os contadores resetados para 0.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade200,
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Limite (±):',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Limite',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: CounterSection(
              title: 'Contador Esquerdo',
              count: _counter1,
              limitValue: _limitValue,
              stepValue: _stepValue1,
              stepController: _stepController1,
              onIncrement: _incrementCounter1,
              onDecrement: _decrementCounter1,
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.grey),
          Expanded(
            child: CounterSection(
              title: 'Contador Direito',
              count: _counter2,
              limitValue: _limitValue,
              stepValue: _stepValue2,
              stepController: _stepController2,
              onIncrement: _incrementCounter2,
              onDecrement: _decrementCounter2,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetAllCounters,
        tooltip: 'Zerar Contadores',
        label: const Text('Zerar Tudo'),
        icon: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class CounterSection extends StatelessWidget {
  final String title;
  final int count;
  final int limitValue;
  final int stepValue;
  final TextEditingController stepController;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterSection({
    super.key,
    required this.title,
    required this.count,
    required this.limitValue,
    required this.stepValue,
    required this.stepController,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final bool incrementDisabled = count >= limitValue;
    final bool decrementDisabled = count <= -limitValue;

    final Color counterColor =
        count == 0 ? Colors.black87 : (count > 0 ? Colors.blue : Colors.red);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          width: 80,
          child: TextField(
            controller: stepController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              // Garante que apenas dígitos sejam inseridos, e impede o primeiro dígito de ser 0
              FilteringTextInputFormatter.allow(
                  RegExp(r'^[1-9][0-9]*|0[0-9]*$')),
            ],
            decoration: const InputDecoration(
              hintText: 'Passo',
              labelText: 'Passo',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: counterColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: counterColor,
              width: 2,
            ),
          ),
          child: Text(
            '$count',
            style: TextStyle(
                fontSize: 48, fontWeight: FontWeight.w900, color: counterColor),
          ),
        ),
        const SizedBox(height: 10),
        if (incrementDisabled || decrementDisabled)
          Text('Limite ±$limitValue Atingido!',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove_circle, size: 40),
              onPressed: decrementDisabled ? null : onDecrement,
              color: decrementDisabled ? Colors.grey : Colors.red,
              tooltip: 'Decrementar em $stepValue',
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.add_circle, size: 40),
              onPressed: incrementDisabled ? null : onIncrement,
              color: incrementDisabled ? Colors.grey : Colors.green,
              tooltip: 'Incrementar em $stepValue',
            ),
          ],
        ),
      ],
    );
  }
}
