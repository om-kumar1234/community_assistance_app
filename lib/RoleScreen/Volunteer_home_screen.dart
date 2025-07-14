// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class VolunteerHomeScreen extends StatefulWidget {
//   const VolunteerHomeScreen({super.key});
//
//   @override
//   State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
// }
//
// class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final TextEditingController _volunteerNameController = TextEditingController();
//   final TextEditingController _volunteerPhoneController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String _selectedHelpType = 'All';
//   String _selectedUrgency = 'All';
//   String _statusFilter = 'Pending';
//
//   final List<String> helpTypes = ['All', 'Food', 'Medical', 'Shelter', 'Accompaniment'];
//   final List<String> urgencies = ['All', 'High', 'Medium', 'Low'];
//   final List<String> statusOptions = ['Pending', 'Accepted', 'Completed'];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadVolunteerInfo();
//   }
//
//   Future<void> _loadVolunteerInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     _volunteerNameController.text = prefs.getString('volunteerName') ?? '';
//     _volunteerPhoneController.text = prefs.getString('volunteerPhone') ?? '';
//   }
//
//   Future<void> _saveVolunteerInfo(String name, String phone) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('volunteerName', name);
//     await prefs.setString('volunteerPhone', phone);
//   }
//
//   Future<void> _acceptRequest(DocumentSnapshot doc) async {
//     final data = doc.data() as Map<String, dynamic>;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Accept Request"),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Text("Help Type: ${data['helpType']}, Description: ${data['description'] ?? ''}"),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _volunteerNameController,
//                   decoration: const InputDecoration(
//                     labelText: "Your Name",
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                   validator: (value) => value == null || value.trim().isEmpty ? 'Name required' : null,
//                 ),
//                 TextFormField(
//                   controller: _volunteerPhoneController,
//                   decoration: const InputDecoration(
//                     labelText: "Phone Number",
//                     prefixIcon: Icon(Icons.phone),
//                   ),
//                   validator: (value) => value == null || value.trim().isEmpty ? 'Phone required' : null,
//                 ),
//                 TextField(
//                   controller: _messageController,
//                   decoration: const InputDecoration(
//                     labelText: "Message to Help Seeker (Optional)",
//                     prefixIcon: Icon(Icons.message),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final name = _volunteerNameController.text.trim();
//                 final phone = _volunteerPhoneController.text.trim();
//                 await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
//                   'status': 'Accepted',
//                   'acceptedBy': {
//                     'name': name,
//                     'phone': phone,
//                     'message': _messageController.text.trim(),
//                     'acceptedAt': Timestamp.now(),
//                     'volunteerMarkedCompleted': false,
//                     'helpSeekerConfirmed': false,
//                   },
//                 });
//                 await _saveVolunteerInfo(name, phone);
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("✅ Request accepted!")),
//                 );
//                 _messageController.clear();
//               }
//             },
//             child: const Text("Confirm Accept"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _markRequestAsCompleted(DocumentSnapshot doc) async {
//     final docRef = FirebaseFirestore.instance.collection('requests').doc(doc.id);
//     await docRef.update({
//       'acceptedBy.volunteerMarkedCompleted': true,
//     });
//     final updatedDoc = await docRef.get();
//     final data = updatedDoc.data() as Map<String, dynamic>;
//     final acceptedBy = data['acceptedBy'] ?? {};
//     if (acceptedBy['helpSeekerConfirmed'] == true) {
//       await docRef.update({'status': 'Completed'});
//     }
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Marked as completed. Awaiting help seeker's confirmation.")),
//     );
//   }
//
//   Stream<QuerySnapshot> _buildFilteredQuery() {
//     Query query = FirebaseFirestore.instance.collection('requests');
//
//     if (_statusFilter == 'Pending') {
//       query = query.where('status', isEqualTo: 'Pending');
//     } else {
//       query = query
//           .where('status', isEqualTo: _statusFilter)
//           .where('acceptedBy.name', isEqualTo: _volunteerNameController.text.trim());
//     }
//
//     if (_statusFilter == 'Pending') {
//       if (_selectedHelpType != 'All') {
//         query = query.where('helpType', isEqualTo: _selectedHelpType);
//       }
//       if (_selectedUrgency != 'All') {
//         query = query.where('urgency', isEqualTo: _selectedUrgency);
//       }
//     }
//
//     return query.orderBy('timestamp', descending: true).snapshots();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Volunteer Dashboard"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (!mounted) return;
//               Navigator.of(context).pushReplacementNamed('/login');
//             },
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               value: _statusFilter,
//               decoration: const InputDecoration(labelText: 'View Requests By Status'),
//               items: statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
//               onChanged: (val) => setState(() => _statusFilter = val!),
//             ),
//             if (_statusFilter == 'Pending')
//               Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: _selectedHelpType,
//                       items: helpTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
//                       decoration: const InputDecoration(labelText: 'Filter by Help Type'),
//                       onChanged: (val) => setState(() => _selectedHelpType = val!),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: _selectedUrgency,
//                       items: urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
//                       decoration: const InputDecoration(labelText: 'Filter by Urgency'),
//                       onChanged: (val) => setState(() => _selectedUrgency = val!),
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _buildFilteredQuery(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     print("❌ Firestore Error: ${snapshot.error.toString()}");
//                     return const Center(child: Text("Error loading requests"));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(child: Text("No $_statusFilter requests."));
//                   }
//
//                   return ListView(
//                     children: snapshot.data!.docs.map((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final timestamp = data['timestamp'] as Timestamp?;
//                       final formattedDate = timestamp != null
//                           ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
//                           : 'N/A';
//
//                       return Card(
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: Colors.blueAccent,
//                             child: Icon(
//                               data['helpType'] == 'Medical'
//                                   ? Icons.medical_services
//                                   : data['helpType'] == 'Food'
//                                   ? Icons.fastfood
//                                   : data['helpType'] == 'Accompaniment'
//                                   ? Icons.accessibility
//                                   : Icons.home,
//                               color: Colors.white,
//                             ),
//                           ),
//                           title: Text("${data['helpType']} - ${data['urgency'] ?? 'N/A'}"),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(data['description'] ?? ''),
//                               Text("Location: ${data['location'] ?? 'N/A'}"),
//                               Text("Contact: ${data['requesterPhone'] ?? ''}"),
//                               Text("Requested on: $formattedDate",
//                                   style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                             ],
//                           ),
//                           trailing: _statusFilter == 'Pending'
//                               ? ElevatedButton(
//                             onPressed: () => _acceptRequest(doc),
//                             child: const Text("Accept"),
//                           )
//                               : _statusFilter == 'Accepted'
//                               ? (data['acceptedBy']['volunteerMarkedCompleted'] == true
//                               ? const Icon(Icons.hourglass_bottom, color: Colors.orange)
//                               : ElevatedButton(
//                             onPressed: () => _markRequestAsCompleted(doc),
//                             child: const Text("Mark Completed"),
//                           ))
//                               : const Icon(Icons.verified, color: Colors.green),
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Enhanced Volunteer Dashboard UI with better responsiveness and visuals
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _volunteerNameController = TextEditingController();
  final TextEditingController _volunteerPhoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, Duration> _countdowns = {};

  void _startCountdown(String docId, DateTime targetDateTime) {
    if (targetDateTime.isBefore(DateTime.now())) return;

    setState(() {
      _countdowns[docId] = targetDateTime.difference(DateTime.now());
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_countdowns.containsKey(docId)) return false;

      final newDiff = targetDateTime.difference(DateTime.now());
      if (newDiff.isNegative) {
        setState(() {
          _countdowns.remove(docId);
        });
        return false;
      }

      setState(() {
        _countdowns[docId] = newDiff;
      });
      return true;
    });
  }


  String _selectedHelpType = 'All';
  String _selectedUrgency = 'All';
  String _statusFilter = 'Pending';

  final List<String> helpTypes = ['All', 'Food', 'Medical', 'Shelter', 'Accompaniment'];
  final List<String> urgencies = ['All', 'High', 'Medium', 'Low'];
  final List<String> statusOptions = ['Pending', 'Accepted', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadVolunteerInfo();
  }

  Future<void> _loadVolunteerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _volunteerNameController.text = prefs.getString('volunteerName') ?? '';
    _volunteerPhoneController.text = prefs.getString('volunteerPhone') ?? '';
  }

  Future<void> _saveVolunteerInfo(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('volunteerName', name);
    await prefs.setString('volunteerPhone', phone);
  }

  Future<void> _acceptRequest(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Accept Request"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Help Type: ${data['helpType']}, Description: ${data['description'] ?? ''}"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _volunteerNameController,
                  decoration: const InputDecoration(
                    labelText: "Your Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Name required' : null,
                ),
                TextFormField(
                  controller: _volunteerPhoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Phone required' : null,
                ),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: "Message to Help Seeker (Optional)",
                    prefixIcon: Icon(Icons.message),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final name = _volunteerNameController.text.trim();
                final phone = _volunteerPhoneController.text.trim();

                await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
                  'status': 'Accepted',
                  'acceptedBy': {
                    'uid': FirebaseAuth.instance.currentUser!.uid,
                    'name': name,
                    'phone': phone,
                    'message': _messageController.text.trim(),
                    'acceptedAt': Timestamp.now(),
                    'volunteerMarkedCompleted': false,
                    'helpSeekerConfirmed': false,
                  },
                });

                await _saveVolunteerInfo(name, phone);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Request accepted!")),
                );
                _messageController.clear();

                // 👉 Start countdown if it's an Accompaniment request
                if (data['helpType'] == 'Accompaniment' &&
                    data['accompanyDate'] != null &&
                    data['accompanyTime'] != null) {
                  final DateTime date = (data['accompanyDate'] as Timestamp).toDate();
                  final String timeStr = data['accompanyTime'];
                  final timeParts = timeStr.split(":");
                  if (timeParts.length >= 2) {
                    final hour = int.tryParse(timeParts[0]) ?? 0;
                    final minute = int.tryParse(timeParts[1].split(" ")[0]) ?? 0;
                    final isPM = timeStr.toLowerCase().contains("pm");

                    final DateTime target = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      isPM && hour < 12 ? hour + 12 : hour,
                      minute,
                    );

                    _startCountdown(doc.id, target); // ⏱️ Start the timer
                  }
                }
              }
            },
            child: const Text("Confirm Accept"),
          )
        ],
      ),
    );
  }


  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}h '
        '${minutes.toString().padLeft(2, '0')}m '
        '${seconds.toString().padLeft(2, '0')}s';
  }

  Stream<QuerySnapshot> _buildFilteredQuery() {
    Query query = FirebaseFirestore.instance.collection('requests');

    if (_statusFilter == 'Pending') {
      query = query.where('status', isEqualTo: 'Pending');
    } else if (_statusFilter == 'Accepted') {
      query = query.where('status', isEqualTo: 'Accepted')
          .where('acceptedBy.uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    } else if (_statusFilter == 'Completed') {
      query = query.where('status', isEqualTo: 'Completed')
          .where('acceptedBy.uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
    }

    if (_statusFilter == 'Pending') {
      if (_selectedHelpType != 'All') {
        query = query.where('helpType', isEqualTo: _selectedHelpType);
      }
      if (_selectedUrgency != 'All') {
        query = query.where('urgency', isEqualTo: _selectedUrgency);
      }
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  Widget _buildRequestCard(Map<String, dynamic> data, VoidCallback? onTapAction, Icon trailingIcon) {
    final timestamp = data['timestamp'] as Timestamp?;
    final formattedDate = timestamp != null
        ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
        : 'N/A';

    final isAccompaniment = data['helpType'] == 'Accompaniment';
    final accompanyDate = data['accompanyDate'] != null
        ? DateFormat('yMMMd').format((data['accompanyDate'] as Timestamp).toDate())
        : null;
    final accompanyTime = data['accompanyTime'] ?? '';
    final destination = data['destination'] ?? '';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.teal,
          child: Icon(
            data['helpType'] == 'Medical'
                ? Icons.medical_services
                : data['helpType'] == 'Food'
                ? Icons.fastfood
                : data['helpType'] == 'Accompaniment'
                ? Icons.accessibility
                : Icons.home,
            color: Colors.white,
          ),
        ),
        title: Text(
          "${data['helpType']} - ${data['urgency'] ?? 'N/A'}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isAccompaniment) Text(data['description'] ?? ''),
              Text("📍 Location: ${data['location'] ?? 'N/A'}"),
              if (isAccompaniment && destination.isNotEmpty) Text("🎯 Destination: $destination"),
              Text("📞 Contact: ${data['requesterPhone'] ?? ''}"),
              Text("⏱ Requested on: $formattedDate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (isAccompaniment && _countdowns.containsKey(data['id'] ?? ''))
                Text(
                  "⏳ Time Left: ${_formatDuration(_countdowns[data['id']])}",
                  style: const TextStyle(color: Colors.redAccent),
                ),

              if (isAccompaniment && accompanyDate != null && accompanyTime.isNotEmpty) ...[
                Text("📅 Accompany Date: $accompanyDate"),
                Text("⏰ Accompany Time: $accompanyTime"),
              ]
            ],
          ),
        ),
        trailing: IconButton(
          icon: trailingIcon,
          tooltip: _statusFilter == 'Accepted' ? 'Mark as Completed' : null,
          onPressed: onTapAction,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteer Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: const InputDecoration(labelText: 'View Requests By Status'),
              items: statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
              onChanged: (val) => setState(() => _statusFilter = val!),
            ),
            if (_statusFilter == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedHelpType,
                      items: helpTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      decoration: const InputDecoration(labelText: 'Help Type'),
                      onChanged: (val) => setState(() => _selectedHelpType = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUrgency,
                      items: urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      decoration: const InputDecoration(labelText: 'Urgency'),
                      onChanged: (val) => setState(() => _selectedUrgency = val!),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildFilteredQuery(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading requests"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No $_statusFilter requests."));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                     data['id'] = doc.id;
                      // Restore countdown for accompaniment requests
                      if (_statusFilter == 'Accepted' &&
                          data['helpType'] == 'Accompaniment' &&
                          !_countdowns.containsKey(doc.id) &&
                          data['accompanyDate'] != null &&
                          data['accompanyTime'] != null) {
                        final DateTime date = (data['accompanyDate'] as Timestamp).toDate();
                        final String timeStr = data['accompanyTime'];
                        final timeParts = timeStr.split(":");

                        if (timeParts.length >= 2) {
                          final hour = int.tryParse(timeParts[0]) ?? 0;
                          final minute = int.tryParse(timeParts[1].split(" ")[0]) ?? 0;
                          final isPM = timeStr.toLowerCase().contains("pm");

                          final DateTime target = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            isPM && hour < 12 ? hour + 12 : hour,
                            minute,
                          );

                          if (target.isAfter(DateTime.now())) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !_countdowns.containsKey(doc.id)) {
                                _startCountdown(doc.id, target); // ✅ Safe now
                              }
                            });
                          }
                        }
                      }


                      final bool volunteerMarkedCompleted =
                          data['acceptedBy']?['volunteerMarkedCompleted'] ?? false;

                      return _buildRequestCard(
                        data,
                        _statusFilter == 'Pending'
                            ? () => _acceptRequest(doc)
                            : _statusFilter == 'Accepted'
                            ? (volunteerMarkedCompleted
                            ? null
                            : () async {
                          await FirebaseFirestore.instance
                              .collection('requests')
                              .doc(doc.id)
                              .update({
                            'acceptedBy.volunteerMarkedCompleted': true,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Marked as completed! Waiting for help seeker confirmation.")),
                          );
                        })
                            : null,
                        _statusFilter == 'Pending'
                            ? const Icon(Icons.pending_actions, color: Colors.amber)
                            : _statusFilter == 'Accepted'
                            ? Icon(
                          volunteerMarkedCompleted ? Icons.done : Icons.assignment_turned_in,
                          color: volunteerMarkedCompleted ? Colors.green : Colors.orange,
                        )
                            : const Icon(Icons.verified, color: Colors.blue),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class VolunteerHomeScreen extends StatefulWidget {
//   const VolunteerHomeScreen({super.key});
//
//   @override
//   State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
// }
//
// class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final TextEditingController _volunteerNameController = TextEditingController();
//   final TextEditingController _volunteerPhoneController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String _selectedHelpType = 'All';
//   String _selectedUrgency = 'All';
//   String _statusFilter = 'Pending';
//
//   final List<String> helpTypes = ['All', 'Food', 'Medical', 'Shelter', 'Accompaniment'];
//   final List<String> urgencies = ['All', 'High', 'Medium', 'Low'];
//   final List<String> statusOptions = ['Pending', 'Accepted', 'Completed'];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadVolunteerInfo().then((_) {
//       setState(() {});
//     });
//   }
//
//   Future<void> _loadVolunteerInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     _volunteerNameController.text = prefs.getString('volunteerName') ?? '';
//     _volunteerPhoneController.text = prefs.getString('volunteerPhone') ?? '';
//   }
//
//   Future<void> _saveVolunteerInfo(String name, String phone) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('volunteerName', name);
//     await prefs.setString('volunteerPhone', phone);
//   }
//
//   Future<void> _acceptRequest(DocumentSnapshot doc) async {
//     final data = doc.data() as Map<String, dynamic>;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Accept Request"),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Text("Help Type: ${data['helpType']}, Description: ${data['description'] ?? ''}"),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _volunteerNameController,
//                   decoration: const InputDecoration(
//                     labelText: "Your Name",
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                   validator: (value) => value == null || value.trim().isEmpty ? 'Name required' : null,
//                 ),
//                 TextFormField(
//                   controller: _volunteerPhoneController,
//                   decoration: const InputDecoration(
//                     labelText: "Phone Number",
//                     prefixIcon: Icon(Icons.phone),
//                   ),
//                   validator: (value) => value == null || value.trim().isEmpty ? 'Phone required' : null,
//                 ),
//                 TextField(
//                   controller: _messageController,
//                   decoration: const InputDecoration(
//                     labelText: "Message to Help Seeker (Optional)",
//                     prefixIcon: Icon(Icons.message),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 final name = _volunteerNameController.text.trim();
//                 final phone = _volunteerPhoneController.text.trim();
//
//                 await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
//                   'status': 'Accepted',
//                   'acceptedBy': {
//                     'uid': FirebaseAuth.instance.currentUser!.uid,
//                     'name': name,
//                     'phone': phone,
//                     'message': _messageController.text.trim(),
//                     'acceptedAt': Timestamp.now(),
//                     'volunteerMarkedCompleted': false,
//                     'helpSeekerConfirmed': false,
//                   },
//                 });
//
//                 await _saveVolunteerInfo(name, phone);
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("✅ Request accepted!")),
//                 );
//                 _messageController.clear();
//               }
//             },
//             child: const Text("Confirm Accept"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Stream<QuerySnapshot> _buildFilteredQuery() {
//     Query query = FirebaseFirestore.instance.collection('requests');
//
//     if (_statusFilter == 'Pending') {
//       query = query.where('status', isEqualTo: 'Pending');
//     } else if (_statusFilter == 'Accepted') {
//       query = query.where('status', isEqualTo: 'Accepted')
//           .where('acceptedBy.uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
//     } else if (_statusFilter == 'Completed') {
//       query = query.where('status', isEqualTo: 'Completed')
//           .where('acceptedBy.uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
//     }
//
//     if (_statusFilter == 'Pending') {
//       if (_selectedHelpType != 'All') {
//         query = query.where('helpType', isEqualTo: _selectedHelpType);
//       }
//       if (_selectedUrgency != 'All') {
//         query = query.where('urgency', isEqualTo: _selectedUrgency);
//       }
//     }
//
//     return query.orderBy('timestamp', descending: true).snapshots();
//   }
//
//   Widget _buildRequestCard(Map<String, dynamic> data, VoidCallback? onTapAction, Icon trailingIcon) {
//     final timestamp = data['timestamp'] as Timestamp?;
//     final formattedDate = timestamp != null
//         ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
//         : 'N/A';
//
//     final isAccompaniment = data['helpType'] == 'Accompaniment';
//     final accompanyDate = data['accompanyDate'] != null
//         ? DateFormat('yMMMd').format((data['accompanyDate'] as Timestamp).toDate())
//         : null;
//     final accompanyTime = data['accompanyTime'] ?? '';
//     final destination = data['destination'] ?? '';
//
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: CircleAvatar(
//           radius: 28,
//           backgroundColor: Colors.teal,
//           child: Icon(
//             data['helpType'] == 'Medical'
//                 ? Icons.medical_services
//                 : data['helpType'] == 'Food'
//                 ? Icons.fastfood
//                 : data['helpType'] == 'Accompaniment'
//                 ? Icons.accessibility
//                 : Icons.home,
//             color: Colors.white,
//           ),
//         ),
//         title: Text(
//           "${data['helpType']} - ${data['urgency'] ?? 'N/A'}",
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!isAccompaniment) Text(data['description'] ?? ''),
//               Text("📍 Location: ${data['location'] ?? 'N/A'}"),
//               if (isAccompaniment && destination.isNotEmpty) Text("🎯 Destination: $destination"),
//               Text("📞 Contact: ${data['requesterPhone'] ?? ''}"),
//               Text("⏱ Requested on: $formattedDate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
//               if (isAccompaniment && accompanyDate != null && accompanyTime.isNotEmpty) ...[
//                 Text("📅 Accompany Date: $accompanyDate"),
//                 Text("⏰ Accompany Time: $accompanyTime"),
//               ]
//             ],
//           ),
//         ),
//         trailing: IconButton(
//           icon: trailingIcon,
//           tooltip: _statusFilter == 'Accepted' ? 'Mark as Completed' : null,
//           onPressed: onTapAction,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Volunteer Dashboard"),
//         backgroundColor: Colors.teal,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (!mounted) return;
//               Navigator.of(context).pushReplacementNamed('/login');
//             },
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               value: _statusFilter,
//               decoration: const InputDecoration(labelText: 'View Requests By Status'),
//               items: statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
//               onChanged: (val) => setState(() => _statusFilter = val!),
//             ),
//             if (_statusFilter == 'Pending')
//               Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: _selectedHelpType,
//                       items: helpTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
//                       decoration: const InputDecoration(labelText: 'Help Type'),
//                       onChanged: (val) => setState(() => _selectedHelpType = val!),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: _selectedUrgency,
//                       items: urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
//                       decoration: const InputDecoration(labelText: 'Urgency'),
//                       onChanged: (val) => setState(() => _selectedUrgency = val!),
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _buildFilteredQuery(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     print("🔥 Firestore error: ${snapshot.error}");
//                     return const Center(child: Text("Error loading requests"));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(child: Text("No $_statusFilter requests."));
//                   }
//
//                   return ListView(
//                     children: snapshot.data!.docs.map((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       data['id'] = doc.id;
//                       final bool volunteerMarkedCompleted =
//                           data['acceptedBy']?['volunteerMarkedCompleted'] ?? false;
//
//                       return _buildRequestCard(
//                         data,
//                         _statusFilter == 'Pending'
//                             ? () => _acceptRequest(doc)
//                             : _statusFilter == 'Accepted'
//                             ? (volunteerMarkedCompleted
//                             ? null
//                             : () async {
//                           await FirebaseFirestore.instance
//                               .collection('requests')
//                               .doc(doc.id)
//                               .update({
//                             'acceptedBy.volunteerMarkedCompleted': true,
//                           });
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("✅ Marked as completed! Waiting for help seeker confirmation.")),
//                           );
//                         })
//                             : null,
//                         _statusFilter == 'Pending'
//                             ? const Icon(Icons.pending_actions, color: Colors.amber)
//                             : _statusFilter == 'Accepted'
//                             ? Icon(
//                           volunteerMarkedCompleted ? Icons.done : Icons.assignment_turned_in,
//                           color: volunteerMarkedCompleted ? Colors.green : Colors.orange,
//                         )
//                             : const Icon(Icons.verified, color: Colors.blue),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

