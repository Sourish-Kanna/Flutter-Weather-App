import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

const String openWeatherMapApiKey = '';  // Enter OpenWeatherAPI Here
const Color Colour = Color(0xFF388BFD);

Future<String?> getCityFromCoordinates(double lat, double lon) async {
  final apiKey = openWeatherMapApiKey;
  final url =
      'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data.isNotEmpty && data[0]['name'] != null) {
      return data[0]['name'];
    }
  }
  return null;
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather & Pollution App',
      theme: ThemeData(
        primaryColor: Colour,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colour,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? selectedCity;
  List<String> cities = ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata'];

  void _useCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    String? city = await getCityFromCoordinates(position.latitude, position.longitude);

    if (city != null) {
      _goToHome(position.latitude, position.longitude, city);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to get city from location.'),
      ));
    }
  }


  void _useSelectedCity() async {
    if (selectedCity == null) return;

    final apiKey = openWeatherMapApiKey;
    final url = 'https://api.openweathermap.org/geo/1.0/direct?q=$selectedCity&limit=1&appid=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = data[0]['lat'];
        final lon = data[0]['lon'];
        _goToHome(lat, lon, selectedCity!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('City not found.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch coordinates.'),
      ));
    }
  }

  void _goToHome(double lat, double lon, String cityName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          latitude: lat,
          longitude: lon,
          locationName: cityName,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud, size: 80, color: Color(0xFF388BFD)),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select a City",
                  border: OutlineInputBorder(),
                ),
                value: selectedCity,
                items: cities
                    .map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedCity = value),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _useSelectedCity,
                child: Text("Use Selected City"),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _useCurrentLocation,
                icon: Icon(Icons.my_location),
                label: Text("Use Current Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const HomePage({required this.latitude, required this.longitude, required this.locationName,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colour,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Location: $locationName",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherPage(
                    latitude: latitude,
                    longitude: longitude,
                    locationName: locationName,
                  ),
                ),
              ),
              child: Text("Check Weather"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PollutionPage(
                    latitude: latitude,
                    longitude: longitude,
                    locationName: locationName,
                  ),
                ),
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
  final double latitude;
  final double longitude;
  final String locationName;

  WeatherPage({required this.latitude, required this.longitude, required this.locationName});

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
    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.deniedForever) {
    //     setState(() => status = "Location permissions are permanently denied.");
    //     return;
    //   }
    // }
    // Position position = await Geolocator.getCurrentPosition();
    String url = 'https://api.openweathermap.org/data/2.5/weather?lat=${widget.latitude}&lon=${widget.longitude}&appid=$openWeatherMapApiKey&units=metric';

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
        backgroundColor: Colour,
        title: Text("Weather Info"),
      ),
      body: Center(
        child: status == "success"
            ? Card(
          color: Color(0xFFF1F8E9),
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Location: ${widget.locationName}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Icon(Icons.wb_sunny, color: Color(0xFFFFEB3B), size: 80),
                SizedBox(height: 16),
                Text(
                  "${temperature.toStringAsFixed(1)}°C",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  weatherDescription.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1.2,
                    color: Color(0xFF000000),
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }
}

class PollutionPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  PollutionPage({required this.latitude, required this.longitude, required this.locationName});

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
    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.deniedForever) {
    //     setState(() => status = "Location permissions are permanently denied.");
    //     return;
    //   }
    // }
    // Position position = await Geolocator.getCurrentPosition();
    String url =
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=${widget.latitude}&lon=${widget.longitude}&appid=$openWeatherMapApiKey';

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
        backgroundColor: Colour,
        title: Text("Air Pollution Info"),
      ),
      body: Center(
        child: status == "success"
            ? Card(
          color: Color(0xFFF1F8E9),
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Location: ${widget.locationName}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Icon(Icons.air, color: Color(0xFFA3A7AC), size: 80),
                SizedBox(height: 16),
                Text(
                  "AQI Level: $aqi",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 16),
                ...components.entries.map((e) => Text(
                  "${e.key.toUpperCase()}: ${e.value}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF000000),
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
            style: TextStyle(fontSize: 18, color: Color(0xFF000000)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
