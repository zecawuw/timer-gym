import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: TimerSetupScreen(),
    );
  }
}

class TimerSetupScreen extends StatefulWidget {
  @override
  _TimerSetupScreenState createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> {
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Time'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Relógio para ajustar o tempo
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ajuste de minutos
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 50,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedMinutes = index.clamp(0, 59);
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          childCount: 60,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  // Ajuste de segundos
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 50,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedSeconds = index.clamp(0, 59);
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          childCount: 60,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Botão Play
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 189, 149, 6),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                // Navegação para a tela do cronômetro, passando o tempo selecionado
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimerScreen(
                      initialTime: Duration(
                        minutes: selectedMinutes,
                        seconds: selectedSeconds,
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.play_arrow, size: 48),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final Duration initialTime;

  TimerScreen({required this.initialTime});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Duration currentTime;
  bool isCountingUp = false;
  late Stopwatch stopwatch;

  @override
  void initState() {
    super.initState();
    currentTime = widget.initialTime;
    stopwatch = Stopwatch();
    startCountdown();
  }

  void startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (currentTime.inSeconds > 0 && mounted) {
        setState(() {
          currentTime -= const Duration(seconds: 1);
        });
        startCountdown();
      } else if (mounted) {
        startCountUp();
      }
    });
  }

  void startCountUp() {
    setState(() {
      isCountingUp = true;
      stopwatch.start();
    });
    countUp();
  }

  void countUp() {
    Future.delayed(const Duration(seconds: 1), () {
      if (stopwatch.isRunning && mounted) {
        setState(() {});
        countUp();
      }
    });
  }

  void resetToInitialTime() {
    setState(() {
      stopwatch.stop();
      stopwatch.reset();
      currentTime = widget.initialTime;
      isCountingUp = false;
    });
    startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: resetToInitialTime,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Time'),
          centerTitle: true,
        ),
        body: Container(
          color: isCountingUp ? const Color(0xFFDE4328) : Colors.grey[800],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fundo escuro para o número
                Padding(
                  padding: const EdgeInsets.all(80),
                  child: Container(
                    color: isCountingUp
                        ? const Color(0xFF9A2E20)
                        : Colors.grey[900],
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      isCountingUp
                          ? stopwatch.elapsed.inMinutes
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0') +
                              ':' +
                              stopwatch.elapsed.inSeconds
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0')
                          : '${currentTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:${currentTime.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 48, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 189, 149, 6),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Retorna para a tela anterior
                  },
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}