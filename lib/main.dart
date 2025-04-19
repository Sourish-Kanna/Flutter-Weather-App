import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather & Pollution App',
      theme: ThemeData(
        primaryColor: Color(0xFFF78125),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF78125),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signIn(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Icon(Icons.cloud, size: 80, color: Color(0xFFF78125)),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFFF78125)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF78125)),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color(0xFFF78125)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF78125)),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _signIn(context),
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF78125),
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WeatherPage()),
              ),
              child: Text("Check Weather"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PollutionPage()),
              ),
              child: Text("Check Air Pollution"),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String weatherDescription = "";
  double temperature = 0.0;
  String status = "Fetching weather...";

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        setState(() => status = "Location permissions are permanently denied.");
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    String apiKey = 'YOUR_API_KEY';
    String url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        weatherDescription = data['weather'][0]['description'];
        temperature = data['main']['temp'];
        status = "success";
      });
    } else {
      setState(() => status = "Failed to fetch weather data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF78125),
        title: Text("Weather Info"),
      ),
      body: Center(
        child: status == "success"
            ? Card(
          color: Color(0xFFFFF3E0),
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny, color: Color(0xFFF78125), size: 80),
                SizedBox(height: 16),
                Text(
                  "${temperature.toStringAsFixed(1)}°C",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF78125),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  weatherDescription.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1.2,
                    color: Color(0xFFF78125),
                  ),
                ),
              ],
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            status,
            style: TextStyle(fontSize: 18, color: Color(0xFFF78125)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class PollutionPage extends StatefulWidget {
  @override
  _PollutionPageState createState() => _PollutionPageState();
}

class _PollutionPageState extends State<PollutionPage> {
  String status = "Fetching air pollution data...";
  int aqi = 0;
  Map<String, dynamic> components = {};

  @override
  void initState() {
    super.initState();
    _getPollution();
  }

  Future<void> _getPollution() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        setState(() => status = "Location permissions are permanently denied.");
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    String apiKey = 'YOUR_API_KEY';
    String url =
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        aqi = data['list'][0]['main']['aqi'];
        components = data['list'][0]['components'];
        status = "success";
      });
    } else {
      setState(() => status = "Failed to fetch air pollution data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF78125),
        title: Text("Air Pollution Info"),
      ),
      body: Center(
        child: status == "success"
            ? Card(
          color: Color(0xFFFFF3E0),
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.air, color: Color(0xFFF78125), size: 80),
                SizedBox(height: 16),
                Text(
                  "AQI Level: $aqi",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF78125),
                  ),
                ),
                SizedBox(height: 16),
                ...components.entries.map((e) => Text(
                  "${e.key.toUpperCase()}: ${e.value}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFF78125),
                  ),
                ))
              ],
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            status,
            style: TextStyle(fontSize: 18, color: Color(0xFFF78125)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
