// Importa o pacote principal do Flutter para usar os widgets e funcionalidades do Material Design.
import 'package:flutter/material.dart';

// A função main() é o ponto de entrada de toda a aplicação Dart.
// runApp() infla o widget principal (neste caso, MyApp) e o anexa à tela.
void main() => runApp(const MyApp());

// MyApp é o widget raiz da aplicação.
// É um StatelessWidget porque seu estado não muda ao longo do tempo.
// Ele define a estrutura geral do app, como o tema e a tela inicial.
class MyApp extends StatelessWidget {
  // Construtor do widget. A chave (key) é usada pelo Flutter para identificar
  // unicamente os widgets na árvore de widgets, o que é útil para performance e estado.
  const MyApp({Key? key}) : super(key: key);

  // O método build() descreve como o widget deve ser renderizado.
  // Ele retorna a árvore de widgets que compõe a UI.
  @override
  Widget build(BuildContext context) {
    // MaterialApp é um widget que envolve vários widgets que são comumente
    // necessários para aplicações Material Design.
    return MaterialApp(
      // Desativa a faixa de "Debug" que aparece no canto superior direito.
      debugShowCheckedModeBanner: false,
      // O título da aplicação, usado pelo sistema operacional (ex: na lista de apps recentes).
      title: 'Calculadora de IMC',
      // Define o tema visual da aplicação.
      theme: ThemeData(
        // Ativa o Material 3, a versão mais recente do design system do Google.
        useMaterial3: true,
        // Define a paleta de cores da aplicação. ColorScheme.fromSeed() gera uma
        // paleta harmoniosa a partir de uma única cor semente (seed color).
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        // Personaliza a aparência padrão dos campos de texto (TextFormField).
        inputDecorationTheme: const InputDecorationTheme(
          // Define uma borda do tipo OutlineInputBorder para todos os campos de texto.
          border: OutlineInputBorder(),
        ),
      ),
      // Define o widget que será a tela inicial (home) da aplicação.
      home: const ImcHomePage(),
    );
  }
}

// ImcHomePage é um StatefulWidget porque seu conteúdo (estado) precisa mudar
// em resposta a interações do usuário (ex: preencher formulário, calcular IMC).
class ImcHomePage extends StatefulWidget {
  const ImcHomePage({Key? key}) : super(key: key);

  // StatefulWidget não tem um método build() diretamente. Em vez disso, ele
  // cria um objeto State que gerencia o estado do widget e contém o método build().
  @override
  State<ImcHomePage> createState() => _ImcHomePageState();
}

// _ImcHomePageState é a classe que gerencia o estado para o ImcHomePage.
// O underscore (_) no início do nome a torna uma classe privada, visível apenas
// dentro deste arquivo (main.dart).
class _ImcHomePageState extends State<ImcHomePage> {
  // Controladores para os campos de texto de peso e altura.
  // Eles permitem ler, escrever e observar o texto nos TextFormFields.
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  // Uma chave global (GlobalKey) para o widget Form.
  // Ela é usada para validar o formulário antes de realizar o cálculo.
  final _formKey = GlobalKey<FormState>();

  // Variáveis de estado para armazenar os resultados do cálculo.
  // O tipo `double?` significa que a variável pode ser um double ou nula (null).
  // Elas são inicializadas como nulas porque não há resultado antes do primeiro cálculo.
  double? _bmi;
  double? _bmiPrime;
  String _category = '';
  Color _categoryColor = Colors.grey.shade300;

  // Uma lista de objetos _ImcCategory que define as faixas de IMC.
  // Cada categoria tem um nome, faixa de IMC (mín/máx), faixa de IMC Prime e uma cor associada.
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

  // Função para calcular o IMC.
  void _calculate() {
    // Valida o formulário usando a GlobalKey. Se os validadores (definidos nos
    // TextFormFields) retornarem algum erro, a função para aqui.
    if (!_formKey.currentState!.validate()) return;

    // Tenta converter o texto dos controllers para números (double).
    // replaceAll(',', '.') permite que o usuário digite tanto vírgula quanto ponto.
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));

    // Se a conversão falhar (retornar null), a função para.
    if (weight == null || height == null) return;

    // Converte a altura para metros. Se o usuário digitou um valor > 10,
    // assume-se que são centímetros (ex: 175) e divide por 100.
    // Caso contrário, assume-se que já está em metros (ex: 1.75).
    final hMeters = height > 10 ? height / 100 : height;

    // Calcula o IMC: peso / (altura em metros)².
    final bmi = weight / (hMeters * hMeters);
    // Calcula o IMC Prime: IMC / 25.0. O IMC Prime normaliza o resultado,
    // onde 1.0 é o limite superior da faixa de peso normal.
    final bmiPrime = bmi / 25.0;

    // Encontra a categoria de IMC correspondente na lista _categories.
    final category = _categories.firstWhere(
      (c) => bmi >= c.min && bmi < c.max,
      // Se nenhuma categoria for encontrada (o que só aconteceria para o valor máximo),
      // usa a última categoria da lista como padrão.
      orElse: () => _categories.last,
    );

    // setState() notifica o Flutter que o estado deste widget mudou.
    // Isso faz com que o método build() seja chamado novamente para reconstruir
    // a UI com os novos valores.
    setState(() {
      _bmi = double.parse(bmi.toStringAsFixed(2)); // Armazena com 2 casas decimais.
      _bmiPrime = double.parse(bmiPrime.toStringAsFixed(2));
      _category = category.name;
      _categoryColor = category.color.withOpacity(0.95);
    });
  }

  // Função para limpar os campos e resetar os resultados.
  void _reset() {
    // Limpa o texto nos controllers.
    _weightController.clear();
    _heightController.clear();
    // Reseta as variáveis de estado para seus valores iniciais.
    setState(() {
      _bmi = null;
      _bmiPrime = null;
      _category = '';
      _categoryColor = Colors.grey.shade300;
    });
  }

  // O método dispose() é chamado quando o widget é removido permanentemente da árvore.
  // É importante liberar recursos, como os controllers, para evitar vazamentos de memória.
  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // O método build() que constrói a interface da tela.
  @override
  Widget build(BuildContext context) {
    // Scaffold é um layout básico do Material Design. Ele fornece uma estrutura
    // para AppBar, corpo (body), FloatingActionButton, etc.
    return Scaffold(
      // A barra no topo da tela.
      appBar: AppBar(
        // O título da AppBar.
        title: Row(
          // mainAxisSize.min faz com que a Row ocupe apenas o espaço necessário.
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mostra a imagem do logo.
            Image.asset(
              'images/logo.png', // O caminho para a imagem do logo.
              height: 30, // Define a altura da imagem.
              // errorBuilder é chamado se a imagem não puder ser carregada.
              // Ele mostra um ícone de balança como fallback.
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.scale, size: 30);
              },
            ),
            const SizedBox(width: 8), // Um espaço horizontal.
            const Text('Calculadora de IMC'),
          ],
        ),
        // Centraliza o título na AppBar.
        centerTitle: true,
        // Adiciona uma pequena sombra abaixo da AppBar.
        elevation: 2,
      ),
      // O corpo principal da tela.
      // SafeArea garante que o conteúdo não seja obstruído por entalhes (notches) ou
      // áreas do sistema operacional.
      body: SafeArea(
        // LayoutBuilder fornece as restrições de tamanho do widget pai (constraints).
        // Isso é usado para criar um layout responsivo.
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Verifica se a largura da tela é maior ou igual a 800 pixels.
            final isWide = constraints.maxWidth >= 800;

            // Padding adiciona um espaçamento interno em todos os lados.
            return Padding(
              padding: const EdgeInsets.all(16.0),
              // Escolhe o layout a ser construído com base na largura da tela.
              child: isWide ? _buildWide(context) : _buildNarrow(context),
            );
          },
        ),
      ),
    );
  }

  // Constrói a interface para telas estreitas (ex: celulares em modo retrato).
  Widget _buildNarrow(BuildContext context) {
    // SingleChildScrollView permite que o conteúdo seja rolado se exceder o tamanho da tela.
    return SingleChildScrollView(
      child: Column(
        // Alinha os filhos para preencher a largura total.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormCard(), // O card do formulário.
          const SizedBox(height: 16), // Espaçamento vertical.
          _buildResultCard(), // O card dos resultados.
          const SizedBox(height: 16),
          _buildLegendCard(), // O card da legenda.
        ],
      ),
    );
  }

  // Constrói a interface para telas largas (ex: tablets, web em desktop).
  Widget _buildWide(BuildContext context) {
    // Row organiza os widgets em uma linha horizontal.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expanded faz com que o filho ocupe o espaço disponível.
        Expanded(
          flex: 5, // 'flex' define a proporção do espaço que este Expanded ocupa.
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
        const SizedBox(width: 16), // Espaçamento horizontal.
        Expanded(
          flex: 4,
          child: _buildResultCard(),
        ),
      ],
    );
  }

  // Constrói o card que contém o formulário de entrada.
  Widget _buildFormCard() {
    return Card(
      // Define a forma do card com bordas arredondadas.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // O widget Form agrupa os campos de formulário e ajuda na validação.
        child: Form(
          key: _formKey, // Associa a GlobalKey ao Form.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Insira seus dados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              // Campo de texto para o peso.
              TextFormField(
                controller: _weightController,
                // Define o tipo de teclado para numérico com decimal.
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                // Personaliza a aparência do campo.
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'ex: 68.5',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                // Validador do campo. Retorna uma string de erro se a validação falhar,
                // ou null se for válido.
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o peso';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Peso inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Campo de texto para a altura.
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
              // Linha com os botões de Calcular e Limpar.
              Row(
                children: [
                  Expanded(
                    // Botão elevado com ícone.
                    child: ElevatedButton.icon(
                      onPressed: _calculate, // Chama a função de cálculo ao ser pressionado.
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calcular'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botão com borda.
                  OutlinedButton(
                    onPressed: _reset, // Chama a função de reset.
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      child: Text('Limpar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Texto de dica.
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

  // Constrói o card que exibe o resultado do cálculo.
  Widget _buildResultCard() {
    // AnimatedContainer permite animar suavemente as mudanças em suas propriedades (como a cor).
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350), // Duração da animação.
      curve: Curves.easeInOut, // Curva de animação para um efeito suave.
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
          // Estrutura condicional: se _bmi for nulo, mostra uma mensagem.
          // Caso contrário, mostra os resultados.
          if (_bmi == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: Text('Preencha os dados e toque em Calcular', textAlign: TextAlign.center)),
            )
          else ...[ // O operador '...' (spread) insere os elementos da lista na árvore.
            _buildResultTile('IMC', _bmi!.toStringAsFixed(2)),
            const SizedBox(height: 8),
            _buildResultTile('IMC Prime', _bmiPrime!.toStringAsFixed(2)),
            const SizedBox(height: 12),
            // Card interno para destacar a categoria.
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
                    _buildCategoryProgress(), // A barra de progresso.
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

  // Constrói uma linha de resultado (ex: "IMC" ...... "22.5").
  Widget _buildResultTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha os itens nas extremidades.
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }

  // Constrói a barra de progresso que mostra a posição do IMC dentro da faixa.
  Widget _buildCategoryProgress() {
    if (_bmi == null) return const SizedBox.shrink(); // Retorna um widget vazio se não houver cálculo.

    // Encontra a categoria atual.
    final cat = _categories.firstWhere((c) => _bmi! >= c.min && _bmi! < c.max, orElse: () => _categories.last);

    // Calcula o progresso dentro da faixa da categoria.
    final min = cat.min.isFinite ? cat.min : 10.0;
    final max = cat.max.isFinite ? cat.max : (cat.min + 20);
    final clamped = _bmi!.clamp(min, max); // Garante que o valor esteja dentro do min/max.
    final progress = (clamped - min) / (max - min); // Normaliza para um valor entre 0.0 e 1.0.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Posição na faixa (${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)})', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        // ClipRRect aplica cantos arredondados ao seu filho.
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: progress, minHeight: 12), // A barra de progresso visual.
        ),
      ],
    );
  }

  // Constrói o card com a legenda das categorias de IMC.
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
            // Mapeia a lista de categorias para uma lista de widgets de legenda.
            ..._categories.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  // O quadradinho colorido.
                  Container(width: 14, height: 14, decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  // O texto da legenda.
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

  // Formata uma faixa de valores (ex: "18.5 – 25.0").
  String _formatRange(double min, double max) {
    if (!min.isFinite) return '< ${_numToStr(max)}';
    if (!max.isFinite) return '≥ ${_numToStr(min)}';
    if (min == max) return _numToStr(min);
    return '${_numToStr(min)} – ${_numToStr(max)}';
  }

  // Converte um número para string, removendo o ".0" se for um inteiro.
  String _numToStr(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  // Gera uma frase explicativa sobre o resultado.
  String _explainCategory() {
    if (_bmi == null || _bmiPrime == null) return '';
    final cat = _categories.firstWhere((c) => _bmi! >= c.min && _bmi! < c.max, orElse: () => _categories.last);
    return 'Seu IMC é $_bmi e IMC Prime é $_bmiPrime. Esta faixa (${_formatRange(cat.min, cat.max)}) indica: ${cat.name}.';
  }
}

// Uma classe simples para agrupar os dados de uma categoria de IMC.
// Isso torna o código mais limpo e organizado do que usar mapas ou listas soltas.
class _ImcCategory {
  final String name;
  final double min;
  final double max;
  final double primeMin;
  final double primeMax;
  final Color color;

  // Construtor da classe.
  _ImcCategory(this.name, this.min, this.max, this.primeMin, this.primeMax, this.color);
}
