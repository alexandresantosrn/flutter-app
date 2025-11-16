import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  // Variáveis de Estado
  int _counter1 = 0;
  int _counter2 = 0;

  // --- Variáveis de Limite Global (Novo Requisito) ---
  int _limitValue = 10; // Valor inicial do limite
  final TextEditingController _limitController =
      TextEditingController(text: '10');

  // --- Variáveis de Passo Individuais ---
  int _stepValue1 = 1;
  int _stepValue2 = 1;
  final TextEditingController _stepController1 =
      TextEditingController(text: '1');
  final TextEditingController _stepController2 =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    // Listeners para atualizar o passo e o limite
    _stepController1.addListener(() => _updateStepValue(1));
    _stepController2.addListener(() => _updateStepValue(2));
    _limitController.addListener(_updateLimitValue);
  }

  @override
  void dispose() {
    _stepController1.dispose();
    _stepController2.dispose();
    _limitController.dispose();
    super.dispose();
  }

  // --- Funções de Atualização de Estado ---

  void _updateLimitValue() {
    // Garante que o limite seja sempre positivo e maior que 0. Se inválido, usa o valor anterior (ou 1, se for o primeiro valor inválido).
    final newLimit = int.tryParse(_limitController.text) ?? 1;

    if (newLimit != _limitValue && newLimit > 0) {
      setState(() {
        _limitValue = newLimit;
        // Opcional: Garante que os contadores fiquem dentro do novo limite ao alterá-lo.
        _counter1 = _counter1.clamp(-_limitValue, _limitValue);
        _counter2 = _counter2.clamp(-_limitValue, _limitValue);
      });
    }
  }

  void _updateStepValue(int counterId) {
    final controller = counterId == 1 ? _stepController1 : _stepController2;
    final currentStep = counterId == 1 ? _stepValue1 : _stepValue2;

    final newStep = int.tryParse(controller.text) ?? 1;

    if (newStep != currentStep && newStep != 0) {
      setState(() {
        if (counterId == 1) {
          _stepValue1 = newStep;
        } else {
          _stepValue2 = newStep;
        }
      });
    }
  }

  // --- Funções de Contagem com Lógica de Limite ---

  void _incrementCounter1() {
    setState(() {
      final nextValue = _counter1 + _stepValue1;
      // Impede que o valor exceda o limite positivo
      if (nextValue <= _limitValue) {
        _counter1 = nextValue;
      } else {
        _counter1 = _limitValue; // Se for exceder, apenas atinge o limite
      }
    });
  }

  void _decrementCounter1() {
    setState(() {
      final nextValue = _counter1 - _stepValue1;
      // Impede que o valor vá além do limite negativo
      if (nextValue >= -_limitValue) {
        _counter1 = nextValue;
      } else {
        _counter1 =
            -_limitValue; // Se for exceder, apenas atinge o limite negativo
      }
    });
  }

  void _incrementCounter2() {
    setState(() {
      final nextValue = _counter2 + _stepValue2;
      if (nextValue <= _limitValue) {
        _counter2 = nextValue;
      } else {
        _counter2 = _limitValue;
      }
    });
  }

  void _decrementCounter2() {
    setState(() {
      final nextValue = _counter2 - _stepValue2;
      if (nextValue >= -_limitValue) {
        _counter2 = nextValue;
      } else {
        _counter2 = -_limitValue;
      }
    });
  }

  void _resetAllCounters() {
    setState(() {
      _counter1 = 0;
      _counter2 = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        // Novo campo de limite na parte inferior da AppBar
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
              ],
            ),
          ),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Contador 1
          Expanded(
            child: CounterSection(
              title: 'Contador Esquerdo',
              count: _counter1,
              limitValue: _limitValue, // Passa o limite global
              stepValue: _stepValue1,
              stepController: _stepController1,
              onIncrement: _incrementCounter1,
              onDecrement: _decrementCounter1,
            ),
          ),

          const VerticalDivider(width: 1, color: Colors.grey),

          // Contador 2
          Expanded(
            child: CounterSection(
              title: 'Contador Direito',
              count: _counter2,
              limitValue: _limitValue, // Passa o limite global
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

// Widget Stateless para o Bloco do Contador
class CounterSection extends StatelessWidget {
  final String title;
  final int count;
  final int limitValue; // Novo parâmetro
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
    // Verifica se os botões devem ser desabilitados
    final bool incrementDisabled = count >= limitValue;
    final bool decrementDisabled = count <= -limitValue;

    // Define a cor do contador: Azul para positivo, Vermelho para negativo, Cinza para zero
    final Color counterColor =
        count == 0 ? Colors.black87 : (count > 0 ? Colors.blue : Colors.red);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),

        // Campo de Texto para o Passo Individual
        SizedBox(
          width: 80,
          child: TextField(
            controller: stepController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
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

        // Container Estilizado para o valor
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

        // Mensagem de Limite
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
            // Botão Decrementar
            IconButton(
              icon: const Icon(Icons.remove_circle, size: 40),
              onPressed: decrementDisabled ? null : onDecrement,
              color: decrementDisabled ? Colors.grey : Colors.red,
              tooltip: 'Decrementar em $stepValue',
            ),

            const SizedBox(width: 20),

            // Botão Incrementar
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
