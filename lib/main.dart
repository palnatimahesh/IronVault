import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const IronVaultApp());
}

// ============================================================================
// 1. DATA & LOGIC ENGINE
// ============================================================================

class AppEngine {
  static final Map<String, List<Map<String, dynamic>>> exerciseDB = {
    "Upper Power": [
      {"name": "Barbell Bench Press", "reps": "3 sets x 3-5", "cue": "Leg drive. Arch back.", "type": "POWER"},
      {"name": "Bent Over Rows", "reps": "3 sets x 3-5", "cue": "Explosive pull.", "type": "POWER"},
      {"name": "Overhead Press", "reps": "3 sets x 6-8", "cue": "Head through window.", "type": "POWER"},
      {"name": "Weighted Pull-Ups", "reps": "3 sets x 6-10", "cue": "Chin over bar.", "type": "POWER"},
      {"name": "Skullcrushers", "reps": "3 sets x 10", "cue": "Elbows in.", "type": "ACCESSORY"},
      {"name": "Barbell Curls", "reps": "3 sets x 10", "cue": "Strict form.", "type": "ACCESSORY"},
    ],
    "Lower Power": [
      {"name": "Barbell Squat", "reps": "3 sets x 3-5", "cue": "Break parallel.", "type": "POWER"},
      {"name": "Deadlift", "reps": "3 sets x 3-5", "cue": "Push the floor away.", "type": "POWER"},
      {"name": "Leg Press", "reps": "3 sets x 10", "cue": "Full depth.", "type": "ACCESSORY"},
      {"name": "Leg Curl", "reps": "3 sets x 12", "cue": "Hips down.", "type": "ACCESSORY"},
      {"name": "Calf Raise", "reps": "4 sets x 15", "cue": "Pause at bottom.", "type": "ACCESSORY"},
    ],
    "Push Hyper": [
      {"name": "Incline DB Press", "reps": "3 sets x 10", "cue": "Upper chest.", "type": "HYPER"},
      {"name": "Seated DB Press", "reps": "3 sets x 12", "cue": "Constant tension.", "type": "HYPER"},
      {"name": "Cable Flys", "reps": "3 sets x 15", "cue": "Squeeze center.", "type": "HYPER"},
      {"name": "Tricep Pushdowns", "reps": "3 sets x 15", "cue": "Lockout.", "type": "HYPER"},
    ],
    "Pull Hyper": [
      {"name": "Barbell Rows", "reps": "4 sets x 10", "cue": "Volume.", "type": "HYPER"},
      {"name": "Lat Pulldown", "reps": "3 sets x 12", "cue": "Control negative.", "type": "HYPER"},
      {"name": "Face Pulls", "reps": "4 sets x 15", "cue": "Rear delts.", "type": "HYPER"},
      {"name": "Hammer Curls", "reps": "3 sets x 12", "cue": "Thumbs up.", "type": "HYPER"},
    ],
    "Legs Hyper": [
      {"name": "Front Squat", "reps": "3 sets x 10", "cue": "Upright torso.", "type": "HYPER"},
      {"name": "RDL", "reps": "3 sets x 12", "cue": "Hamstring stretch.", "type": "HYPER"},
      {"name": "Leg Extensions", "reps": "3 sets x 15", "cue": "Squeeze quads.", "type": "HYPER"},
      {"name": "Lunges", "reps": "3 sets x 20", "cue": "Knee to floor.", "type": "HYPER"},
    ],
    "Bicep Blaster": [
      {"name": "Barbell Curl", "reps": "4 sets x 8", "cue": "Heavy load.", "type": "FOCUS"},
      {"name": "Incline Curl", "reps": "3 sets x 10", "cue": "Long head stretch.", "type": "FOCUS"},
      {"name": "Preacher Curl", "reps": "3 sets x 12", "cue": "Short head peak.", "type": "FOCUS"},
    ],
    "Tricep Torture": [
      {"name": "Close Grip Bench", "reps": "4 sets x 8", "cue": "Power builder.", "type": "FOCUS"},
      {"name": "Skullcrushers", "reps": "3 sets x 10", "cue": "Medial head.", "type": "FOCUS"},
      {"name": "Rope Pushdown", "reps": "3 sets x 15", "cue": "Lateral head.", "type": "FOCUS"},
    ],
  };

  static final Map<String, Map<String, String>> guideChapters = {
    "1. The Philosophy": {
      "subtitle": "POWER HYPERTROPHY ADAPTIVE TRAINING",
      "body": "The 'Hybrid Athlete' needs Strength and Size. PHAT combines them.\n\n• Days 1-2: Power (3-5 Reps). Builds density.\n• Days 4-6: Hypertrophy (8-15 Reps). Builds size.\n\nHeavy lifting builds the engine. Volume builds the fuel tank."
    },
    "2. The RAMP Warmup": {
      "subtitle": "STOP STRETCHING COLD MUSCLES",
      "body": "Static stretching reduces power. Use RAMP:\n\n• R (Raise): Sweat before you lift.\n• A (Activate): Glute bridges, Band pulls.\n• M (Mobilize): Dynamic arm circles.\n• P (Potentiate): Warmup sets (Bar -> 50% -> 70% -> Work)."
    },
    "3. Mechanics: The Big 3": {
      "subtitle": "TECHNICAL MASTERY",
      "body": "SQUAT: Tripod foot. Break the bar across traps. Hip crease below knee.\n\nBENCH: Retract scapula. Leg drive backward. Bar path is a 'J' curve.\n\nDEADLIFT: Pull slack out of bar until it clicks. Push the earth away."
    },
    "4. Progressive Overload": {
      "subtitle": "THE LAW OF GROWTH",
      "body": "You must do more than last time.\n\n1. Intensity: +2.5kg (The King).\n2. Volume: +1 Rep.\n3. Density: Less rest.\n4. Technique: Slower reps."
    },
    "5. Equipment Guide": {
      "subtitle": "CHOOSE YOUR WEAPON",
      "body": "BARBELLS: Main lifts (1-6 reps). Max load.\n\nDUMBBELLS: Secondary lifts. Fixes imbalances.\n\nCABLES: Constant tension. Isolation.\n\nMACHINES: Failure training safely."
    },
  };

  static String calculatePlates(String weight) {
    double? w = double.tryParse(weight);
    if (w == null || w < 20) return "Bar Only (20kg)";
    
    double remaining = (w - 20) / 2;
    List<double> plates = [25, 20, 15, 10, 5, 2.5, 1.25];
    List<String> loaded = [];

    for (var p in plates) {
      while (remaining >= p) {
        loaded.add(p.toString().replaceAll(".0", ""));
        remaining -= p;
      }
    }
    
    if (loaded.isEmpty) return "Bar Only";
    return "Side: ${loaded.join(', ')}";
  }

  static String calculate1RM(String weight, String reps) {
    double? w = double.tryParse(weight);
    int? r = int.tryParse(reps);
    if (w == null || r == null) return "0";
    if (r == 1) return w.toStringAsFixed(1);
    return (w * (1 + r / 30)).toStringAsFixed(1);
  }
}

// ============================================================================
// 2. MAIN APP WIDGET
// ============================================================================

class IronVaultApp extends StatelessWidget {
  const IronVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iron Vault',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00FF88),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Color(0xFF00FF88),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF88),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88),
          secondary: Color(0xFF00CC6A),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================================
// 3. HOME SCREEN
// ============================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IRON VAULT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const GuideMenuScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ToolsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("PHAT SYSTEM"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildWorkoutBtn(context, "UPPER POWER", "Upper Power", Colors.redAccent)),
              const SizedBox(width: 10),
              Expanded(child: _buildWorkoutBtn(context, "LOWER POWER", "Lower Power", Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildWorkoutBtn(context, "PUSH HYP", "Push Hyper", Colors.blueAccent)),
              const SizedBox(width: 10),
              Expanded(child: _buildWorkoutBtn(context, "PULL HYP", "Pull Hyper", Colors.blueAccent)),
              const SizedBox(width: 10),
              Expanded(child: _buildWorkoutBtn(context, "LEGS HYP", "Legs Hyper", Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionHeader("SPECIALTY SPLITS"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildWorkoutBtn(context, "BICEPS", "Bicep Blaster", Colors.orangeAccent)),
              const SizedBox(width: 10),
              Expanded(child: _buildWorkoutBtn(context, "TRICEPS", "Tricep Torture", Colors.orangeAccent)),
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionHeader("HISTORY"),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen())),
            icon: const Icon(Icons.history),
            label: const Text("VIEW LOGS"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFF00FF88), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );
  }

  Widget _buildWorkoutBtn(BuildContext context, String label, String key, Color color) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.2), foregroundColor: color),
        onPressed: () {
          List<Map<String, dynamic>>? workout = AppEngine.exerciseDB[key];
          if (workout != null) {
            Navigator.push(context, MaterialPageRoute(builder: (c) => WorkoutScreen(title: label, exercises: workout)));
          }
        },
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

// ============================================================================
// 4. WORKOUT SCREEN
// ============================================================================

class WorkoutScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> exercises;

  const WorkoutScreen({super.key, required this.title, required this.exercises});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int index = 0;
  int timerSeconds = 90;
  Timer? _timer;
  bool isResting = false;
  
  final TextEditingController weightCtrl = TextEditingController();
  final TextEditingController repsCtrl = TextEditingController();

  // Helper to save log
  Future<void> _saveLog() async {
    if (weightCtrl.text.isEmpty || repsCtrl.text.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    String exName = widget.exercises[index]['name'];
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String logEntry = "$date|$exName|${weightCtrl.text}|${repsCtrl.text}";
    
    List<String> logs = prefs.getStringList('logs') ?? [];
    logs.add(logEntry);
    await prefs.setStringList('logs', logs);

    // Save Last Best
    await prefs.setString('last_$exName', "${weightCtrl.text}kg x ${repsCtrl.text}");

    _startRest();
  }

  void _startRest() {
    setState(() {
      isResting = true;
      timerSeconds = 90;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timerSeconds > 0) {
            timerSeconds--;
          } else {
            isResting = false;
            timer.cancel();
          }
        });
      }
    });
  }

  void _nextExercise() {
    _timer?.cancel();
    setState(() {
      if (index < widget.exercises.length - 1) {
        index++;
        isResting = false;
        weightCtrl.clear();
        repsCtrl.clear();
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    weightCtrl.dispose();
    repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercises[index];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (index + 1) / widget.exercises.length,
              backgroundColor: Colors.grey[800],
              color: const Color(0xFF00FF88),
            ),
            const SizedBox(height: 20),
            
            // Exercise Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  Text(
                    ex['type'],
                    style: const TextStyle(color: Color(0xFF00FF88), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ex['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "TARGET: ${ex['reps']}",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "CUE: ${ex['cue']}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Rest Timer
            Center(
              child: Text(
                isResting ? "REST: ${timerSeconds}s" : "GO!",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isResting ? Colors.redAccent : const Color(0xFF00FF88),
                ),
              ),
            ),
            
            const Spacer(),

            // Inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Weight (kg)",
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF88))),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Reps",
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF88))),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveLog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color(0xFF00FF88), 
                    ),
                    child: const Text("LOG SET", style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextExercise,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.grey[800],
                    ),
                    child: const Text("NEXT >", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. TOOLS SCREEN
// ============================================================================

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController _plateCtrl = TextEditingController();
  final TextEditingController _rmWeightCtrl = TextEditingController();
  final TextEditingController _rmRepsCtrl = TextEditingController();
  String _plateResult = "Load: ";
  String _rmResult = "Max: ";

  void _calcPlate() {
    setState(() {
      _plateResult = AppEngine.calculatePlates(_plateCtrl.text);
    });
  }

  void _calcRM() {
    setState(() {
      _rmResult = "Max: ${AppEngine.calculate1RM(_rmWeightCtrl.text, _rmRepsCtrl.text)}kg";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VETERAN TOOLS")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("PLATE CALCULATOR", style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _plateCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: "Target Weight (kg)", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _calcPlate, child: const Text("CALCULATE")),
          const SizedBox(height: 10),
          Text(_plateResult, style: const TextStyle(fontSize: 18, color: Colors.white)),
          
          const Divider(height: 40, color: Colors.grey),
          
          const Text("1RM ESTIMATOR", style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _rmWeightCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Weight", border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _rmRepsCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Reps", border: OutlineInputBorder()))),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _calcRM, child: const Text("ESTIMATE")),
          const SizedBox(height: 10),
          Text(_rmResult, style: const TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. GUIDE SCREEN
// ============================================================================

class GuideMenuScreen extends StatelessWidget {
  const GuideMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLACK BOOK")),
      body: ListView(
        children: AppEngine.guideChapters.keys.map((title) {
          return ListTile(
            title: Text(title, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF00FF88)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => GuideContentScreen(
                    title: title,
                    data: AppEngine.guideChapters[title]!,
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class GuideContentScreen extends StatelessWidget {
  final String title;
  final Map<String, String> data;

  const GuideContentScreen({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['subtitle']!,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              data['body']!,
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. HISTORY SCREEN
// ============================================================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      logs = prefs.getStringList('logs')?.reversed.toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TRAINING LOG")),
      body: logs.isEmpty
          ? const Center(child: Text("No logs yet. Go lift!", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final parts = logs[index].split('|');
                // parts: [Date, Name, Weight, Reps]
                return ListTile(
                  leading: const Icon(Icons.fitness_center, color: Color(0xFF00FF88)),
                  title: Text(parts[1], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("${parts[0]} - ${parts[2]}kg x ${parts[3]} reps", style: const TextStyle(color: Colors.grey)),
                );
              },
            ),
    );
  }
}
