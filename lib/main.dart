import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora de IMC',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ImcHomePage(),
    );
  }
}

class ImcHomePage extends StatefulWidget {
  const ImcHomePage({Key? key}) : super(key: key);

  @override
  State<ImcHomePage> createState() => _ImcHomePageState();
}

class _ImcHomePageState extends State<ImcHomePage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _bmi;
  double? _bmiPrime;
  String _category = '';
  Color _categoryColor = Colors.grey.shade300;

  // Table ranges (BMI) and corresponding IMC Prime ranges
  final List<_ImcCategory> _categories = [
    _ImcCategory('Abaixo do peso (magreza extrema)', double.negativeInfinity, 16.0, 0, 0.64, Colors.indigo),
    _ImcCategory('Abaixo do peso (magreza moderada)', 16.0, 17.0, 0.64, 0.68, Colors.blue),
    _ImcCategory('Abaixo do peso (leve magreza)', 17.0, 18.5, 0.68, 0.74, Colors.lightBlue),
    _ImcCategory('Faixa normal', 18.5, 25.0, 0.74, 1.00, Colors.green),
    _ImcCategory('Sobrepeso (Pré-obesidade)', 25.0, 30.0, 1.00, 1.20, Colors.amber),
    _ImcCategory('Obeso (Classe I)', 30.0, 35.0, 1.20, 1.40, Colors.orange),
    _ImcCategory('Obeso (Classe II)', 35.0, 40.0, 1.40, 1.60, Colors.deepOrange),
    _ImcCategory('Obeso (Classe III)', 40.0, double.infinity, 1.60, double.infinity, Colors.red),
  ];

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    if (weight == null || height == null) return;

    // height is expected in centimeters; convert to meters
    final hMeters = height > 10 ? height / 100 : height; // if user already provided meters

    final bmi = weight / (hMeters * hMeters);
    final bmiPrime = bmi / 25.0; // IMC Prime defined with reference to 25 -> 1.0

    final category = _categories.firstWhere(
      (c) => bmi >= c.min && bmi < c.max,
      orElse: () => _categories.last,
    );

    setState(() {
      _bmi = double.parse(bmi.toStringAsFixed(2));
      _bmiPrime = double.parse(bmiPrime.toStringAsFixed(2));
      _category = category.name;
      _categoryColor = category.color.withOpacity(0.95);
    });
  }

  void _reset() {
    _weightController.clear();
    _heightController.clear();
    setState(() {
      _bmi = null;
      _bmiPrime = null;
      _category = '';
      _categoryColor = Colors.grey.shade300;
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/logo.png', // Caminho para o seu logo
              height: 30, // Ajuste a altura conforme necessário
              errorBuilder: (context, error, stackTrace) {
                // Caso o logo não carregue, mostra o ícone de balança
                return const Icon(Icons.scale, size: 30);
              },
            ),
            const SizedBox(width: 8),
            const Text('Calculadora de IMC'),
          ],
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: isWide ? _buildWide(context) : _buildNarrow(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNarrow(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormCard(),
          const SizedBox(height: 16),
          _buildResultCard(),
          const SizedBox(height: 16),
          _buildLegendCard(),
        ],
      ),
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildFormCard(),
                const SizedBox(height: 16),
                _buildLegendCard(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 4, child: _buildResultCard()),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Insira seus dados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'ex: 68.5',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o peso';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Peso inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Altura (cm ou m)',
                  hintText: 'ex: 175 ou 1.75',
                  prefixIcon: Icon(Icons.height),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe a altura';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Altura inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calcular'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _reset,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      child: Text('Limpar'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Dica: você pode inserir altura em centímetros (ex: 175) ou metros (ex: 1.75). IMC = peso / (altura²). IMC Prime = IMC / 25.0',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _categoryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _categoryColor.withOpacity(0.18)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Resultado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (_bmi == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: Text('Preencha os dados e toque em Calcular', textAlign: TextAlign.center)),
            )
          else ...[
            _buildResultTile('IMC', _bmi!.toStringAsFixed(2)),
            const SizedBox(height: 8),
            _buildResultTile('IMC Prime', _bmiPrime!.toStringAsFixed(2)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: _categoryColor.withOpacity(0.16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildCategoryProgress(),
                    const SizedBox(height: 8),
                    Text(_explainCategory(), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }

  Widget _buildCategoryProgress() {
    if (_bmi == null) return const SizedBox.shrink();

    final cat = _categories.firstWhere((c) => _bmi! >= c.min && _bmi! < c.max, orElse: () => _categories.last);

    // calculate progress inside this category's BMI range
    final min = cat.min.isFinite ? cat.min : 10.0; // clamp for display
    final max = cat.max.isFinite ? cat.max : (cat.min + 20);
    final clamped = _bmi!.clamp(min, max);
    final progress = (clamped - min) / (max - min);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posição na faixa (${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)})', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: progress, minHeight: 12),
        ),
      ],
    );
  }

  Widget _buildLegendCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tabela de referência', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._categories.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(width: 14, height: 14, decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${c.name} — ${_formatRange(c.min, c.max)} (IMC Prime ${_formatRange(c.primeMin, c.primeMax)})')),
                ],
              ),
            )).toList(),
            const SizedBox(height: 8),
            const Text('Observação: a tabela utiliza IMC (kg/m²) e IMC Prime. IMC Prime é calculado como IMC / 25.0, e serve para comparar ao limite superior da "faixa normal" (25 -> 1.0).', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatRange(double min, double max) {
    if (!min.isFinite) return '< ${_numToStr(max)}';
    if (!max.isFinite) return '≥ ${_numToStr(min)}';
    if (min == max) return _numToStr(min);
    return '${_numToStr(min)} – ${_numToStr(max)}';
  }

  String _numToStr(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  String _explainCategory() {
    if (_bmi == null || _bmiPrime == null) return '';
    final cat = _categories.firstWhere((c) => _bmi! >= c.min && _bmi! < c.max, orElse: () => _categories.last);
    return 'Seu IMC é $_bmi e IMC Prime é $_bmiPrime. Esta faixa (${_formatRange(cat.min, cat.max)}) indica: ${cat.name}.';
  }
}

class _ImcCategory {
  final String name;
  final double min;
  final double max;
  final double primeMin;
  final double primeMax;
  final Color color;

  _ImcCategory(this.name, this.min, this.max, this.primeMin, this.primeMax, this.color);
}
