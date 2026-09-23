import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/trip.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Trip>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _refreshTrips();
  }

  void _refreshTrips() {
    setState(() {
      _tripsFuture = _dbHelper.getTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF894B35);
    const Color surfaceColor = Color(0xFFFBF9F4);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: const Text(
          'My Saved Trips',
          style: TextStyle(
            fontFamily: 'Serif',
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: FutureBuilder<List<Trip>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No trips saved yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addDummyTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text(
                      'Add a Sample Trip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final trips = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    trip.destination,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${trip.numberOfDays} days',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Budget: ${trip.budget} • ${trip.numberOfPeople} people',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      if (trip.id != null) {
                        final messenger = ScaffoldMessenger.of(context);
                        await _dbHelper.deleteTrip(trip.id!);
                        if (!mounted) return;
                        _refreshTrips();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Trip deleted')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDummyTrip,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _addDummyTrip() async {
    final newTrip = Trip(
      userId: 1,
      destination: 'New Adventure',
      numberOfDays: 3,
      budget: '₹10,000',
      numberOfPeople: 2,
    );
    await _dbHelper.insertTrip(newTrip);
    _refreshTrips();
  }
}
