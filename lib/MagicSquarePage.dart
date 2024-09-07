import 'package:flutter/material.dart';

class MagicSquarePage extends StatefulWidget {
  const MagicSquarePage({super.key});

  @override
  _MagicSquarePageState createState() => _MagicSquarePageState();
}

class _MagicSquarePageState extends State<MagicSquarePage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> controllers =
      List.generate(9, (index) => TextEditingController());
  final List<bool> hasError = List.generate(9, (index) => false);
  final List<String?> errorMessages = List.generate(9, (index) => null);
  String resultMessage = '';
  bool _isDarkMode = false; // Variable para gestionar el estado del fondo
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  bool isMagicSquare(List<int> square) {
    const magicSum = 15;
    return (square[0] + square[1] + square[2] == magicSum && // Row 1
        square[3] + square[4] + square[5] == magicSum && // Row 2
        square[6] + square[7] + square[8] == magicSum && // Row 3
        square[0] + square[3] + square[6] == magicSum && // Column 1
        square[1] + square[4] + square[7] == magicSum && // Column 2
        square[2] + square[5] + square[8] == magicSum && // Column 3
        square[0] + square[4] + square[8] == magicSum && // Diagonal 1
        square[2] + square[4] + square[6] == magicSum); // Diagonal 2
  }

  void validateSquare() {
    setState(() {
      resultMessage = '';
      bool isValid = true;
      List<int> square = [];
      Set<int> seenNumbers = {};

      for (int i = 0; i < 9; i++) {
        try {
          int value = int.parse(controllers[i].text);
          if (value < 1 || value > 9) {
            hasError[i] = true;
            errorMessages[i] = 'Debe estar entre 1 y 9';
            isValid = false;
          } else {
            if (seenNumbers.contains(value)) {
              hasError[i] = true;
              errorMessages[i] = 'Duplicado';
              isValid = false;
            } else {
              square.add(value);
              seenNumbers.add(value);
              hasError[i] = false;
              errorMessages[i] = null;
            }
          }
        } catch (e) {
          hasError[i] = true;
          errorMessages[i] = 'Desconocido';
          isValid = false;
        }
      }

      if (isValid) {
        if (seenNumbers.length != 9) {
          setState(() {
            resultMessage = 'Ingresa números únicos entre 1 y 9.';
            isValid = false;
          });
        } else {
          setState(() {
            resultMessage = isMagicSquare(square)
                ? '¡Es un cuadrado mágico!'
                : 'No es un cuadrado mágico.';
          });
        }
      } else {
        if (resultMessage.isEmpty) {
          resultMessage = 'Por favor, corrige los errores en los campos.';
        }
      }

      _animationController.forward(from: 0);
    });
  }

  void toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validador de Cuadrado Mágico'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.brightness_7 : Icons.brightness_2),
            onPressed: toggleDarkMode,
          ),
        ],
      ),
      body: Container(
        color: _isDarkMode ? Colors.black : Colors.white, // Fondo basado en el modo
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return TextField(
                      controller: controllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: hasError[index] ? Colors.red : Colors.grey,
                          ),
                        ),
                        errorText: errorMessages[index],
                        fillColor: _isDarkMode ? Colors.grey[800] : Colors.white,
                        filled: true,
                      ),
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: validateSquare,
                child: const Text('Validar Cuadrado Mágico'),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  resultMessage,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }
}
