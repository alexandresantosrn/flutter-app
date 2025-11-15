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
      home: const DualCounterPage(title: 'Contadores Independentes'),
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
    // Listeners separados para cada campo de passo
    _stepController1.addListener(() => _updateStepValue(1));
    _stepController2.addListener(() => _updateStepValue(2));
  }

  @override
  void dispose() {
    _stepController1.dispose();
    _stepController2.dispose();
    super.dispose();
  }

  // Função Única para atualizar o valor do passo
  void _updateStepValue(int counterId) {
    final controller = counterId == 1 ? _stepController1 : _stepController2;
    final currentStep = counterId == 1 ? _stepValue1 : _stepValue2;

    // Tenta converter o texto para inteiro, se falhar ou for 0, usa 1
    final newStep = int.tryParse(controller.text) ?? 1;

    // Atualiza o estado apenas se o novo passo for válido (não zero) e diferente
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

  // --- Funções de Contagem (Sem Limites) ---

  void _incrementCounter1() {
    setState(() {
      _counter1 += _stepValue1; // Usa _stepValue1
    });
  }

  void _decrementCounter1() {
    setState(() {
      _counter1 -= _stepValue1; // Usa _stepValue1
    });
  }

  void _incrementCounter2() {
    setState(() {
      _counter2 += _stepValue2; // Usa _stepValue2
    });
  }

  void _decrementCounter2() {
    setState(() {
      _counter2 -= _stepValue2; // Usa _stepValue2
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Contador 1 (Passo Variável Individual)
          Expanded(
            child: CounterSection(
              title: 'Contador Esquerdo',
              count: _counter1,
              stepValue: _stepValue1, // Passa o valor do passo 1
              stepController: _stepController1, // Passa o controlador 1
              onIncrement: _incrementCounter1,
              onDecrement: _decrementCounter1,
            ),
          ),

          const VerticalDivider(width: 1, color: Colors.grey),

          // Contador 2 (Passo Variável Individual)
          Expanded(
            child: CounterSection(
              title: 'Contador Direito',
              count: _counter2,
              stepValue: _stepValue2, // Passa o valor do passo 2
              stepController: _stepController2, // Passa o controlador 2
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

// Novo Widget Stateless para o Bloco do Contador
class CounterSection extends StatelessWidget {
  final String title;
  final int count;
  final int stepValue;
  final TextEditingController stepController;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterSection({
    super.key,
    required this.title,
    required this.count,
    required this.stepValue,
    required this.stepController,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
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
              FilteringTextInputFormatter.digitsOnly, // Apenas dígitos
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
            color: count == 0
                ? Colors.grey[300]
                : (count > 0
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: count == 0
                  ? Colors.grey
                  : (count > 0 ? Colors.blue : Colors.red),
              width: 2,
            ),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black87),
          ),
        ),

        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Botão Decrementar
            IconButton(
              icon:
                  const Icon(Icons.remove_circle, size: 40, color: Colors.red),
              onPressed: onDecrement,
              tooltip: 'Decrementar em $stepValue',
            ),

            const SizedBox(width: 20),

            // Botão Incrementar
            IconButton(
              icon: const Icon(Icons.add_circle, size: 40, color: Colors.green),
              onPressed: onIncrement,
              tooltip: 'Incrementar em $stepValue',
            ),
          ],
        ),
      ],
    );
  }
}
