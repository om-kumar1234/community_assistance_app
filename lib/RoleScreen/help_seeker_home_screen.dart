// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class HelpSeekerHomeScreen extends StatefulWidget {
//   const HelpSeekerHomeScreen({super.key});
//
//   @override
//   State<HelpSeekerHomeScreen> createState() => _HelpSeekerHomeScreenState();
// }
//
// class _HelpSeekerHomeScreenState extends State<HelpSeekerHomeScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _descriptionController = TextEditingController();
//   String _selectedHelpType = 'Food';
//
//   final helpTypes = ['Food', 'Medical', 'Shelter'];
//
//   Future<void> submitRequest() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     await FirebaseFirestore.instance.collection('requests').add({
//       'requesterId': user.uid,
//       'requesterName': user.email ?? '',
//       'helpType': _selectedHelpType,
//       'description': _descriptionController.text.trim(),
//       'timestamp': Timestamp.now(),
//       'status': 'Pending',
//       'acceptedBy': null,
//     });
//
//     _descriptionController.clear();
//     setState(() => _selectedHelpType = 'Food');
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Request submitted successfully!")),
//     );
//   }
//   void _logout() async {
//     await FirebaseAuth.instance.signOut();
//     if (!mounted) return;
//     Navigator.of(context).pushReplacementNamed('/login'); // Replace with your login route
//   }
//
//
//   Future<void> _editRequest(DocumentSnapshot doc) async {
//     final data = doc.data() as Map<String, dynamic>;
//     _descriptionController.text = data['description'];
//     _selectedHelpType = data['helpType'];
//
//     String newType = _selectedHelpType;
//     TextEditingController tempDesc = TextEditingController(text: _descriptionController.text);
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Request'),
//         content: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               DropdownButtonFormField<String>(
//                 value: newType,
//                 items: helpTypes.map((type) {
//                   return DropdownMenuItem(value: type, child: Text(type));
//                 }).toList(),
//                 onChanged: (value) => newType = value!,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: tempDesc,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 validator: (value) =>
//                 value == null || value.isEmpty ? 'Required' : null,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               if (_formKey.currentState!.validate()) {
//                 await FirebaseFirestore.instance
//                     .collection('requests')
//                     .doc(doc.id)
//                     .update({
//                   'helpType': newType,
//                   'description': tempDesc.text.trim(),
//                 });
//
//                 _descriptionController.clear();
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Request updated!")),
//                 );
//               }
//             },
//             child: const Text('Update'),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _deleteRequest(DocumentSnapshot doc) async {
//     await FirebaseFirestore.instance.collection('requests').doc(doc.id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Request deleted.")),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Help-Seeker Dashboard"),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: "Logout",
//             onPressed: _logout,
//           )
//         ],
//       ),
//
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   DropdownButtonFormField<String>(
//                     value: _selectedHelpType,
//                     items: helpTypes.map((type) {
//                       return DropdownMenuItem(value: type, child: Text(type));
//                     }).toList(),
//                     onChanged: (value) =>
//                         setState(() => _selectedHelpType = value!),
//                     decoration: const InputDecoration(
//                       labelText: "Type of Help",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _descriptionController,
//                     decoration: const InputDecoration(
//                       labelText: "Describe your need",
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) =>
//                     value == null || value.isEmpty ? 'Required' : null,
//                   ),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: submitRequest,
//                     child: const Text("Submit Request"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const Divider(thickness: 1),
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text("Your Requests",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('requests')
//                   .where('requesterId', isEqualTo: user?.uid)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (snapshot.hasError) {
//                   print("Firestore Stream Error: ${snapshot.error}");
//                   return const Center(child: Text("Error loading requests"));
//                 }
//
//                 final docs = snapshot.data?.docs ?? [];
//
//                 if (docs.isEmpty) {
//                   return const Center(child: Text("No requests found."));
//                 }
//
//                 return ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final doc = docs[index];
//                     final data = doc.data() as Map<String, dynamic>;
//
//                     return Card(
//                       margin:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       child: ListTile(
//                         leading: Icon(
//                           data['helpType'] == 'Medical'
//                               ? Icons.medical_services
//                               : data['helpType'] == 'Food'
//                               ? Icons.fastfood
//                               : Icons.home,
//                         ),
//                         title: Text(data['helpType']),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(data['description']),
//                             Text("Status: ${data['status']}",
//                                 style: TextStyle(
//                                   color: data['status'] == 'Pending'
//                                       ? Colors.orange
//                                       : data['status'] == 'Accepted'
//                                       ? Colors.green
//                                       : Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                 )),
//                           ],
//                         ),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (value) {
//                             if (value == 'edit') {
//                               _editRequest(doc);
//                             } else if (value == 'delete') {
//                               _deleteRequest(doc);
//                             }
//                           },
//                           itemBuilder: (context) => const [
//                             PopupMenuItem(value: 'edit', child: Text('Edit')),
//                             PopupMenuItem(value: 'delete', child: Text('Delete')),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// Full upgraded HelpSeekerHomeScreen with:
// 1. Edit/Delete support restored
// 2. Status filtering fixed
// Updated HelpSeekerHomeScreen with:
// 1. Submission success dialog
// 2. Timestamp display
// 3. "NEW" badge for unseen accepted requests
// Updated HelpSeekerHomeScreen with:
// 1. Submission success dialog
// 2. Timestamp display
// 3. "NEW" badge for unseen accepted requests
// 4. Re-added the request form at the top
// Updated HelpSeekerHomeScreen with:
// 1. Submission success dialog
// 2. Timestamp display
// 3. "NEW" badge for unseen accepted requests
// 4. Re-added the request form at the top
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class HelpSeekerHomeScreen extends StatefulWidget {
//   const HelpSeekerHomeScreen({super.key});
//
//   @override
//   State<HelpSeekerHomeScreen> createState() => _HelpSeekerHomeScreenState();
// }
//
// class _HelpSeekerHomeScreenState extends State<HelpSeekerHomeScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   String _selectedHelpType = 'Food';
//   String _selectedUrgency = 'Medium';
//   String _selectedStatus = 'All';
//
//   final helpTypes = ['Food', 'Medical', 'Shelter'];
//   final urgencies = ['High', 'Medium', 'Low'];
//   final statusOptions = ['All', 'Pending', 'Accepted', 'Completed'];
//
//   Future<void> submitRequest() async {
//     if (!_formKey.currentState!.validate()) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     await FirebaseFirestore.instance.collection('requests').add({
//       'requesterId': user.uid,
//       'requesterName': _nameController.text.trim(),
//       'requesterPhone': _phoneController.text.trim(),
//       'helpType': _selectedHelpType,
//       'urgency': _selectedUrgency,
//       'location': _locationController.text.trim(),
//       'description': _descriptionController.text.trim(),
//       'timestamp': Timestamp.now(),
//       'status': 'Pending',
//       'seenByRequester': true,
//       'acceptedBy': null,
//     });
//
//     _nameController.clear();
//     _phoneController.clear();
//     _locationController.clear();
//     _descriptionController.clear();
//     setState(() => _selectedHelpType = 'Food');
//
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("✅ Success"),
//         content: const Text("Your request has been submitted successfully!"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("OK"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _editRequest(DocumentSnapshot doc) async {
//     final data = doc.data() as Map<String, dynamic>;
//     _nameController.text = data['requesterName'] ?? '';
//     _phoneController.text = data['requesterPhone'] ?? '';
//     _locationController.text = data['location'] ?? '';
//     _descriptionController.text = data['description'] ?? '';
//     _selectedHelpType = data['helpType'] ?? 'Food';
//     _selectedUrgency = data['urgency'] ?? 'Medium';
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Request'),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: "Full Name"),
//                 ),
//                 TextFormField(
//                   controller: _phoneController,
//                   decoration: const InputDecoration(labelText: "Phone Number"),
//                 ),
//                 TextFormField(
//                   controller: _locationController,
//                   decoration: const InputDecoration(labelText: "Location"),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _selectedHelpType,
//                   decoration: const InputDecoration(labelText: "Type of Help"),
//                   items: helpTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
//                   onChanged: (v) => setState(() => _selectedHelpType = v!),
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _selectedUrgency,
//                   decoration: const InputDecoration(labelText: "Urgency Level"),
//                   items: urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
//                   onChanged: (v) => setState(() => _selectedUrgency = v!),
//                 ),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: const InputDecoration(labelText: "Describe your need"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
//                 'requesterName': _nameController.text.trim(),
//                 'requesterPhone': _phoneController.text.trim(),
//                 'location': _locationController.text.trim(),
//                 'helpType': _selectedHelpType,
//                 'urgency': _selectedUrgency,
//                 'description': _descriptionController.text.trim(),
//               });
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("✅ Request updated!")),
//               );
//             },
//             child: const Text("Update"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _deleteRequest(DocumentSnapshot doc) async {
//     await FirebaseFirestore.instance.collection('requests').doc(doc.id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("🗑️ Request deleted.")),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     Query baseQuery = FirebaseFirestore.instance
//         .collection('requests')
//         .where('requesterId', isEqualTo: user?.uid);
//     if (_selectedStatus != 'All') {
//       baseQuery = baseQuery.where('status', isEqualTo: _selectedStatus);
//     }
//     baseQuery = baseQuery.orderBy('timestamp', descending: true);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Help-Seeker Dashboard"),
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
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         const Text("Submit Help Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: const InputDecoration(
//                             labelText: "Full Name",
//                             prefixIcon: Icon(Icons.person),
//                           ),
//                           validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _phoneController,
//                           decoration: const InputDecoration(
//                             labelText: "Phone Number",
//                             prefixIcon: Icon(Icons.phone),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _locationController,
//                           decoration: const InputDecoration(
//                             labelText: "Location",
//                             prefixIcon: Icon(Icons.location_on),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         DropdownButtonFormField<String>(
//                           value: _selectedHelpType,
//                           decoration: const InputDecoration(
//                             labelText: "Type of Help",
//                             prefixIcon: Icon(Icons.volunteer_activism),
//                           ),
//                           items: helpTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
//                           onChanged: (v) => setState(() => _selectedHelpType = v!),
//                         ),
//                         const SizedBox(height: 12),
//                         DropdownButtonFormField<String>(
//                           value: _selectedUrgency,
//                           decoration: const InputDecoration(
//                             labelText: "Urgency Level",
//                             prefixIcon: Icon(Icons.priority_high),
//                           ),
//                           items: urgencies.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
//                           onChanged: (v) => setState(() => _selectedUrgency = v!),
//                         ),
//                         const SizedBox(height: 12),
//                         TextFormField(
//                           controller: _descriptionController,
//                           maxLines: 2,
//                           decoration: const InputDecoration(
//                             labelText: "Describe your need",
//                             prefixIcon: Icon(Icons.description),
//                           ),
//                           validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton.icon(
//                             onPressed: submitRequest,
//                             icon: const Icon(Icons.send),
//                             label: const Text("Submit Request"),
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: DropdownButtonFormField<String>(
//                 value: _selectedStatus,
//                 decoration: const InputDecoration(
//                   labelText: 'Filter by Status',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.filter_alt),
//                 ),
//                 items: statusOptions.map((status) => DropdownMenuItem(
//                   value: status, child: Text(status),
//                 )).toList(),
//                 onChanged: (v) => setState(() => _selectedStatus = v!),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("Your Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ),
//             ),
//             StreamBuilder<QuerySnapshot>(
//               stream: baseQuery.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   print("❌ Firestore query error: ${snapshot.error}");
//                   return const Center(child: Text("Error loading requests"));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(child: Text("No requests yet."));
//                 }
//
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final doc = snapshot.data!.docs[index];
//                     final data = doc.data() as Map<String, dynamic>;
//                     final timestamp = data['timestamp'] as Timestamp?;
//                     final formattedDate = timestamp != null
//                         ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
//                         : 'N/A';
//
//                     final statusColor = data['status'] == 'Pending'
//                         ? Colors.orange
//                         : data['status'] == 'Accepted'
//                         ? Colors.green
//                         : Colors.grey;
//
//                     final showNewBadge =
//                         data['status'] == 'Accepted' && data['seenByRequester'] == false;
//
//                     if (showNewBadge) {
//                       FirebaseFirestore.instance
//                           .collection('requests')
//                           .doc(doc.id)
//                           .update({'seenByRequester': true});
//                     }
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                       elevation: 2,
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           child: Icon(
//                             data['helpType'] == 'Medical'
//                                 ? Icons.medical_services
//                                 : data['helpType'] == 'Food'
//                                 ? Icons.fastfood
//                                 : Icons.home,
//                           ),
//                         ),
//                         title: Row(
//                           children: [
//                             Text("${data['helpType']} (${data['urgency']})"),
//                             const SizedBox(width: 6),
//                             if (showNewBadge)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.redAccent,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: const Text("NEW", style: TextStyle(color: Colors.white, fontSize: 10)),
//                               ),
//                           ],
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(data['description'] ?? ''),
//                             Text("Location: ${data['location'] ?? 'N/A'}"),
//                             Text("Contact: ${data['requesterPhone'] ?? ''}"),
//                             Text("Requested on: $formattedDate",
//                                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                           ],
//                         ),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (value) {
//                             if (value == 'edit') {
//                               _editRequest(doc);
//                             } else if (value == 'delete') {
//                               _deleteRequest(doc);
//                             }
//                           },
//                           itemBuilder: (context) => const [
//                             PopupMenuItem(value: 'edit', child: Text('Edit')),
//                             PopupMenuItem(value: 'delete', child: Text('Delete')),
//                           ],
//                           child: Chip(
//                             label: Text(data['status'] ?? ''),
//                             backgroundColor: statusColor.withOpacity(0.2),
//                             labelStyle: TextStyle(color: statusColor),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class HelpSeekerHomeScreen extends StatefulWidget {
//   const HelpSeekerHomeScreen({super.key});
//
//   @override
//   State<HelpSeekerHomeScreen> createState() => _HelpSeekerHomeScreenState();
// }
//
// class _HelpSeekerHomeScreenState extends State<HelpSeekerHomeScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   String _selectedHelpType = 'Food';
//   String _selectedUrgency = 'Medium';
//   String _selectedStatus = 'All';
//
//   final helpTypes = ['Food', 'Medical', 'Shelter'];
//   final urgencies = ['High', 'Medium', 'Low'];
//   final statusOptions = ['All', 'Pending', 'Accepted', 'Completed'];
//
//   Future<void> submitRequest() async {
//     if (!_formKey.currentState!.validate()) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     await FirebaseFirestore.instance.collection('requests').add({
//       'requesterId': user.uid,
//       'requesterName': _nameController.text.trim(),
//       'requesterPhone': _phoneController.text.trim(),
//       'helpType': _selectedHelpType,
//       'urgency': _selectedUrgency,
//       'location': _locationController.text.trim(),
//       'description': _descriptionController.text.trim(),
//       'timestamp': Timestamp.now(),
//       'status': 'Pending',
//       'seenByRequester': true,
//       'acceptedBy': null,
//     });
//
//     _nameController.clear();
//     _phoneController.clear();
//     _locationController.clear();
//     _descriptionController.clear();
//     setState(() => _selectedHelpType = 'Food');
//
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("✅ Success"),
//         content: const Text("Your request has been submitted successfully!"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("OK"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _editRequest(DocumentSnapshot doc) async {
//     final data = doc.data() as Map<String, dynamic>;
//     _nameController.text = data['requesterName'] ?? '';
//     _phoneController.text = data['requesterPhone'] ?? '';
//     _locationController.text = data['location'] ?? '';
//     _descriptionController.text = data['description'] ?? '';
//     _selectedHelpType = data['helpType'] ?? 'Food';
//     _selectedUrgency = data['urgency'] ?? 'Medium';
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Request'),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTextField(_nameController, 'Full Name', Icons.person),
//                 _buildTextField(_phoneController, 'Phone Number', Icons.phone),
//                 _buildTextField(_locationController, 'Location', Icons.location_on),
//                 _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
//                         (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
//                 _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
//                         (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
//                 _buildTextField(_descriptionController, 'Describe your need', Icons.description),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
//                 'requesterName': _nameController.text.trim(),
//                 'requesterPhone': _phoneController.text.trim(),
//                 'location': _locationController.text.trim(),
//                 'helpType': _selectedHelpType,
//                 'urgency': _selectedUrgency,
//                 'description': _descriptionController.text.trim(),
//               });
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("✅ Request updated!")),
//               );
//             },
//             child: const Text("Update"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _deleteRequest(DocumentSnapshot doc) async {
//     await FirebaseFirestore.instance.collection('requests').doc(doc.id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("🗑️ Request deleted.")),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[100],
//           prefixIcon: Icon(icon),
//         ),
//         validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//       ),
//     );
//   }
//
//   Widget _buildDropdown(List<String> items, String value, String label, void Function(String) onChanged, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[100],
//           prefixIcon: Icon(icon),
//         ),
//         items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
//         onChanged: (v) => onChanged(v!),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     Query baseQuery = FirebaseFirestore.instance
//         .collection('requests')
//         .where('requesterId', isEqualTo: user?.uid);
//     if (_selectedStatus != 'All') {
//       baseQuery = baseQuery.where('status', isEqualTo: _selectedStatus);
//     }
//     baseQuery = baseQuery.orderBy('timestamp', descending: true);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Help-Seeker Dashboard"),
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       _buildTextField(_nameController, 'Full Name', Icons.person),
//                       _buildTextField(_phoneController, 'Phone Number', Icons.phone),
//                       _buildTextField(_locationController, 'Location', Icons.location_on),
//                       _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
//                               (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
//                       _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
//                               (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
//                       _buildTextField(_descriptionController, 'Describe your need', Icons.description),
//                       const SizedBox(height: 12),
//                       ElevatedButton.icon(
//                         onPressed: submitRequest,
//                         icon: const Icon(Icons.send),
//                         label: const Text("Submit Request"),
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildDropdown(statusOptions, _selectedStatus, 'Filter by Status',
//                     (v) => setState(() => _selectedStatus = v), Icons.filter_alt),
//             const SizedBox(height: 12),
//             const Text("Your Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 8),
//             StreamBuilder<QuerySnapshot>(
//               stream: baseQuery.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return const Text("Error loading requests");
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Text("No requests yet.");
//                 }
//                 return ListView(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: snapshot.data!.docs.map((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final timestamp = data['timestamp'] as Timestamp?;
//                     final formattedDate = timestamp != null
//                         ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
//                         : 'N/A';
//
//                     final statusColor = data['status'] == 'Pending'
//                         ? Colors.orange
//                         : data['status'] == 'Accepted'
//                         ? Colors.green
//                         : Colors.grey;
//
//                     final showNewBadge =
//                         data['status'] == 'Accepted' && data['seenByRequester'] == false;
//
//                     if (showNewBadge) {
//                       FirebaseFirestore.instance
//                           .collection('requests')
//                           .doc(doc.id)
//                           .update({'seenByRequester': true});
//                     }
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       elevation: 1,
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           child: Icon(
//                             data['helpType'] == 'Medical'
//                                 ? Icons.medical_services
//                                 : data['helpType'] == 'Food'
//                                 ? Icons.fastfood
//                                 : Icons.home,
//                           ),
//                         ),
//                         title: Row(
//                           children: [
//                             Expanded(
//                               child: Text("${data['helpType']} (${data['urgency']})",
//                                   style: const TextStyle(fontWeight: FontWeight.bold)),
//                             ),
//                             if (showNewBadge)
//                               Container(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.redAccent,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: const Text("NEW",
//                                     style: TextStyle(color: Colors.white, fontSize: 10)),
//                               ),
//                           ],
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(data['description'] ?? ''),
//                             Text("Location: ${data['location'] ?? 'N/A'}"),
//                             Text("Contact: ${data['requesterPhone'] ?? ''}"),
//                             Text("Requested on: $formattedDate",
//                                 style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                           ],
//                         ),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (value) {
//                             if (value == 'edit') {
//                               _editRequest(doc);
//                             } else if (value == 'delete') {
//                               _deleteRequest(doc);
//                             }
//                           },
//                           itemBuilder: (context) => const [
//                             PopupMenuItem(value: 'edit', child: Text('Edit')),
//                             PopupMenuItem(value: 'delete', child: Text('Delete')),
//                           ],
//                           child: Chip(
//                             label: Text(data['status'] ?? ''),
//                             backgroundColor: statusColor.withOpacity(0.2),
//                             labelStyle: TextStyle(color: statusColor),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class HelpSeekerHomeScreen extends StatefulWidget {
//   const HelpSeekerHomeScreen({super.key});
//
//   @override
//   State<HelpSeekerHomeScreen> createState() => _HelpSeekerHomeScreenState();
// }
//
// class _HelpSeekerHomeScreenState extends State<HelpSeekerHomeScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   String _selectedHelpType = 'Food';
//   String _selectedUrgency = 'Medium';
//   String _selectedStatus = 'All';
//
//   final helpTypes = ['Food', 'Medical', 'Shelter'];
//   final urgencies = ['High', 'Medium', 'Low'];
//   final statusOptions = ['All', 'Pending', 'Accepted', 'Completed'];
//
//   Future<void> submitRequest() async {
//     if (!_formKey.currentState!.validate()) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     await FirebaseFirestore.instance.collection('requests').add({
//       'requesterId': user.uid,
//       'requesterName': _nameController.text.trim(),
//       'requesterPhone': _phoneController.text.trim(),
//       'helpType': _selectedHelpType,
//       'urgency': _selectedUrgency,
//       'location': _locationController.text.trim(),
//       'description': _descriptionController.text.trim(),
//       'timestamp': Timestamp.now(),
//       'status': 'Pending',
//       'seenByRequester': true,
//       'acceptedBy': null,
//     });
//
//     _nameController.clear();
//     _phoneController.clear();
//     _locationController.clear();
//     _descriptionController.clear();
//     setState(() => _selectedHelpType = 'Food');
//
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("✅ Success"),
//         content: const Text("Your request has been submitted successfully!"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("OK"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _editRequest(DocumentSnapshot doc) async {
//     final data = doc.data() as Map<String, dynamic>;
//     _nameController.text = data['requesterName'] ?? '';
//     _phoneController.text = data['requesterPhone'] ?? '';
//     _locationController.text = data['location'] ?? '';
//     _descriptionController.text = data['description'] ?? '';
//     _selectedHelpType = data['helpType'] ?? 'Food';
//     _selectedUrgency = data['urgency'] ?? 'Medium';
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Request'),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTextField(_nameController, 'Full Name', Icons.person),
//                 _buildTextField(_phoneController, 'Phone Number', Icons.phone),
//                 _buildTextField(_locationController, 'Location', Icons.location_on),
//                 _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
//                         (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
//                 _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
//                         (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
//                 _buildTextField(_descriptionController, 'Describe your need', Icons.description),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
//                 'requesterName': _nameController.text.trim(),
//                 'requesterPhone': _phoneController.text.trim(),
//                 'location': _locationController.text.trim(),
//                 'helpType': _selectedHelpType,
//                 'urgency': _selectedUrgency,
//                 'description': _descriptionController.text.trim(),
//               });
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("✅ Request updated!")),
//               );
//             },
//             child: const Text("Update"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _deleteRequest(DocumentSnapshot doc) async {
//     await FirebaseFirestore.instance.collection('requests').doc(doc.id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("🗑️ Request deleted.")),
//     );
//   }
//
//   Future<void> _verifyCompletion(String docId) async {
//     await FirebaseFirestore.instance.collection('requests').doc(docId).update({
//       'status': 'Completed',
//       'acceptedBy.helpSeekerConfirmed': true,
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("✅ Marked as completed!")),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[100],
//           prefixIcon: Icon(icon),
//         ),
//         validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//       ),
//     );
//   }
//
//   Widget _buildDropdown(List<String> items, String value, String label, void Function(String) onChanged, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[100],
//           prefixIcon: Icon(icon),
//         ),
//         items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
//         onChanged: (v) => onChanged(v!),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     Query baseQuery = FirebaseFirestore.instance
//         .collection('requests')
//         .where('requesterId', isEqualTo: user?.uid);
//     if (_selectedStatus != 'All') {
//       baseQuery = baseQuery.where('status', isEqualTo: _selectedStatus);
//     }
//     baseQuery = baseQuery.orderBy('timestamp', descending: true);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Help-Seeker Dashboard"),
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       _buildTextField(_nameController, 'Full Name', Icons.person),
//                       _buildTextField(_phoneController, 'Phone Number', Icons.phone),
//                       _buildTextField(_locationController, 'Location', Icons.location_on),
//                       _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
//                               (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
//                       _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
//                               (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
//                       _buildTextField(_descriptionController, 'Describe your need', Icons.description),
//                       const SizedBox(height: 12),
//                       ElevatedButton.icon(
//                         onPressed: submitRequest,
//                         icon: const Icon(Icons.send),
//                         label: const Text("Submit Request"),
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildDropdown(statusOptions, _selectedStatus, 'Filter by Status',
//                     (v) => setState(() => _selectedStatus = v), Icons.filter_alt),
//             const SizedBox(height: 12),
//             const Text("Your Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 8),
//             StreamBuilder<QuerySnapshot>(
//               stream: baseQuery.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return const Text("Error loading requests");
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Text("No requests yet.");
//                 }
//                 return ListView(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: snapshot.data!.docs.map((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final timestamp = data['timestamp'] as Timestamp?;
//                     final formattedDate = timestamp != null
//                         ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
//                         : 'N/A';
//
//                     final statusColor = data['status'] == 'Pending'
//                         ? Colors.orange
//                         : data['status'] == 'Accepted'
//                         ? Colors.green
//                         : Colors.grey;
//
//                     final showNewBadge =
//                         data['status'] == 'Accepted' && data['seenByRequester'] == false;
//
//                     if (showNewBadge) {
//                       FirebaseFirestore.instance
//                           .collection('requests')
//                           .doc(doc.id)
//                           .update({'seenByRequester': true});
//                     }
//
//                     final volunteerInfo = data['acceptedBy'] as Map<String, dynamic>?;
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       elevation: 1,
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           child: Icon(
//                             data['helpType'] == 'Medical'
//                                 ? Icons.medical_services
//                                 : data['helpType'] == 'Food'
//                                 ? Icons.fastfood
//                                 : Icons.home,
//                           ),
//                         ),
//                         title: Row(
//                           children: [
//                             Expanded(
//                               child: Text("${data['helpType']} (${data['urgency']})",
//                                   style: const TextStyle(fontWeight: FontWeight.bold)),
//                             ),
//                             if (showNewBadge)
//                               Container(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.redAccent,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: const Text("NEW",
//                                     style: TextStyle(color: Colors.white, fontSize: 10)),
//                               ),
//                           ],
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(data['description'] ?? ''),
//                             Text("Location: ${data['location'] ?? 'N/A'}"),
//                             Text("Contact: ${data['requesterPhone'] ?? ''}"),
//                             Text("Requested on: $formattedDate",
//                                 style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                             if (data['status'] == 'Accepted' && volunteerInfo != null) ...[
//                               const Divider(),
//                               const Text("Accepted by:", style: TextStyle(fontWeight: FontWeight.bold)),
//                               Text("Name: ${volunteerInfo['name'] ?? ''}"),
//                               Text("Phone: ${volunteerInfo['phone'] ?? ''}"),
//                               Text("Message: ${volunteerInfo['message'] ?? ''}"),
//                               if (volunteerInfo['volunteerMarkedCompleted'] == true &&
//                                   volunteerInfo['helpSeekerConfirmed'] != true)
//                                 TextButton.icon(
//                                   icon: const Icon(Icons.verified_user),
//                                   label: const Text("Mark as Completed"),
//                                   onPressed: () => _verifyCompletion(doc.id),
//                                 ),
//                             ]
//                           ],
//                         ),
//                         trailing: PopupMenuButton<String>(
//                           onSelected: (value) {
//                             if (value == 'edit') {
//                               _editRequest(doc);
//                             } else if (value == 'delete') {
//                               _deleteRequest(doc);
//                             }
//                           },
//                           itemBuilder: (context) => const [
//                             PopupMenuItem(value: 'edit', child: Text('Edit')),
//                             PopupMenuItem(value: 'delete', child: Text('Delete')),
//                           ],
//                           child: Chip(
//                             label: Text(data['status'] ?? ''),
//                             backgroundColor: statusColor.withOpacity(0.2),
//                             labelStyle: TextStyle(color: statusColor),
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class HelpSeekerHomeScreen extends StatefulWidget {
//   const HelpSeekerHomeScreen({super.key});
//
//   @override
//   State<HelpSeekerHomeScreen> createState() => _HelpSeekerHomeScreenState();
// }
//
// class _HelpSeekerHomeScreenState extends State<HelpSeekerHomeScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   String _selectedHelpType = 'Food';
//   String _selectedUrgency = 'Medium';
//   String _selectedStatus = 'All';
//
//   final helpTypes = ['Food', 'Medical', 'Shelter', 'Accompaniment'];
//   final urgencies = ['High', 'Medium', 'Low'];
//   final statusOptions = ['All', 'Pending', 'Accepted', 'Completed'];
//
//   Future<void> submitRequest() async {
//     if (!_formKey.currentState!.validate()) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     await FirebaseFirestore.instance.collection('requests').add({
//       'requesterId': user.uid,
//       'requesterName': _nameController.text.trim(),
//       'requesterPhone': _phoneController.text.trim(),
//       'helpType': _selectedHelpType,
//       'urgency': _selectedUrgency,
//       'location': _locationController.text.trim(),
//       'description': _descriptionController.text.trim(),
//       'timestamp': Timestamp.now(),
//       'status': 'Pending',
//       'seenByRequester': true,
//       'acceptedBy': null,
//       'helpSeekerConfirmed': false,
//     });
//
//     _nameController.clear();
//     _phoneController.clear();
//     _locationController.clear();
//     _descriptionController.clear();
//     setState(() => _selectedHelpType = 'Food');
//
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("✅ Success"),
//         content: const Text("Your request has been submitted successfully!"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("OK"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _editRequest(DocumentSnapshot doc) async {
//     final data = doc.data() as Map<String, dynamic>;
//     _nameController.text = data['requesterName'] ?? '';
//     _phoneController.text = data['requesterPhone'] ?? '';
//     _locationController.text = data['location'] ?? '';
//     _descriptionController.text = data['description'] ?? '';
//     _selectedHelpType = data['helpType'] ?? 'Food';
//     _selectedUrgency = data['urgency'] ?? 'Medium';
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Request'),
//         content: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildTextField(_nameController, 'Full Name', Icons.person),
//                 _buildTextField(_phoneController, 'Phone Number', Icons.phone),
//                 _buildTextField(_locationController, 'Location', Icons.location_on),
//                 _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
//                         (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
//                 _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
//                         (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
//                 _buildTextField(_descriptionController, 'Describe your need', Icons.description),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
//                 'requesterName': _nameController.text.trim(),
//                 'requesterPhone': _phoneController.text.trim(),
//                 'location': _locationController.text.trim(),
//                 'helpType': _selectedHelpType,
//                 'urgency': _selectedUrgency,
//                 'description': _descriptionController.text.trim(),
//               });
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("✅ Request updated!")),
//               );
//             },
//             child: const Text("Update"),
//           )
//         ],
//       ),
//     );
//   }
//
//   Future<void> _deleteRequest(DocumentSnapshot doc) async {
//     await FirebaseFirestore.instance.collection('requests').doc(doc.id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("🗑️ Request deleted.")),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[100],
//           prefixIcon: Icon(icon),
//         ),
//         validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//       ),
//     );
//   }
//
//   Widget _buildDropdown(List<String> items, String value, String label, void Function(String) onChanged, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//           filled: true,
//           fillColor: Colors.grey[100],
//           prefixIcon: Icon(icon),
//         ),
//         items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
//         onChanged: (v) => onChanged(v!),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     Query baseQuery = FirebaseFirestore.instance
//         .collection('requests')
//         .where('requesterId', isEqualTo: user?.uid);
//     if (_selectedStatus != 'All') {
//       baseQuery = baseQuery.where('status', isEqualTo: _selectedStatus);
//     }
//     baseQuery = baseQuery.orderBy('timestamp', descending: true);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Help-Seeker Dashboard"),
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       _buildTextField(_nameController, 'Full Name', Icons.person),
//                       _buildTextField(_phoneController, 'Phone Number', Icons.phone),
//                       _buildTextField(_locationController, 'Location', Icons.location_on),
//                       _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
//                               (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
//                       _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
//                               (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
//                       _buildTextField(_descriptionController, 'Describe your need', Icons.description),
//                       const SizedBox(height: 12),
//                       ElevatedButton.icon(
//                         onPressed: submitRequest,
//                         icon: const Icon(Icons.send),
//                         label: const Text("Submit Request"),
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildDropdown(statusOptions, _selectedStatus, 'Filter by Status',
//                     (v) => setState(() => _selectedStatus = v), Icons.filter_alt),
//             const SizedBox(height: 12),
//             const Text("Your Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 8),
//             StreamBuilder<QuerySnapshot>(
//               stream: baseQuery.snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return const Text("Error loading requests");
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Text("No requests yet.");
//                 }
//                 return ListView(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   children: snapshot.data!.docs.map((doc) {
//                     final data = doc.data() as Map<String, dynamic>;
//                     final timestamp = data['timestamp'] as Timestamp?;
//                     final formattedDate = timestamp != null
//                         ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
//                         : 'N/A';
//
//                     final statusColor = data['status'] == 'Pending'
//                         ? Colors.orange
//                         : data['status'] == 'Accepted'
//                         ? Colors.green
//                         : Colors.grey;
//
//                     final showNewBadge =
//                         data['status'] == 'Accepted' && data['seenByRequester'] == false;
//
//                     if (showNewBadge) {
//                       FirebaseFirestore.instance
//                           .collection('requests')
//                           .doc(doc.id)
//                           .update({'seenByRequester': true});
//                     }
//
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 6),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       elevation: 1,
//                       child: Column(
//                         children: [
//                           ListTile(
//                             leading: CircleAvatar(
//                               child: Icon(
//                                 data['helpType'] == 'Medical'
//                                     ? Icons.medical_services
//                                     : data['helpType'] == 'Food'
//                                     ? Icons.fastfood
//                                     : data['helpType'] == 'Accompaniment'
//                                     ? Icons.accessibility
//                                     : Icons.home,
//                               ),
//                             ),
//                             title: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text("${data['helpType']} (${data['urgency']})",
//                                       style: const TextStyle(fontWeight: FontWeight.bold)),
//                                 ),
//                                 if (showNewBadge)
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: Colors.redAccent,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Text("NEW",
//                                         style: TextStyle(color: Colors.white, fontSize: 10)),
//                                   ),
//                               ],
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(data['description'] ?? ''),
//                                 Text("Location: ${data['location'] ?? 'N/A'}"),
//                                 Text("Contact: ${data['requesterPhone'] ?? ''}"),
//                                 Text("Requested on: $formattedDate",
//                                     style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//                                 if (data['status'] == 'Accepted' && data['acceptedBy'] != null) ...[
//                                   const SizedBox(height: 10),
//                                   const Divider(),
//                                   Text("Volunteer Details:", style: TextStyle(fontWeight: FontWeight.bold)),
//                                   Text("Name: ${data['acceptedBy']['name'] ?? ''}"),
//                                   Text("Phone: ${data['acceptedBy']['phone'] ?? ''}"),
//                                   if (data['acceptedBy']['message'] != null && data['acceptedBy']['message'].toString().isNotEmpty)
//                                     Text("Message: ${data['acceptedBy']['message']}")
//                                 ],
//                                 if (data['status'] == 'Accepted' && !(data['helpSeekerConfirmed'] ?? false))
//                                   TextButton.icon(
//                                     icon: const Icon(Icons.check_circle_outline, color: Colors.teal),
//                                     label: const Text("Mark as Completed"),
//                                     onPressed: () async {
//                                       await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
//                                         'status': 'Completed',
//                                         'helpSeekerConfirmed': true
//                                       });
//                                     },
//                                   ),
//                               ],
//                             ),
//                             trailing: data['status'] == 'Pending'
//                                 ? PopupMenuButton<String>(
//                               onSelected: (value) {
//                                 if (value == 'edit') {
//                                   _editRequest(doc);
//                                 } else if (value == 'delete') {
//                                   _deleteRequest(doc);
//                                 }
//                               },
//                               itemBuilder: (context) => const [
//                                 PopupMenuItem(value: 'edit', child: Text('Edit')),
//                                 PopupMenuItem(value: 'delete', child: Text('Delete')),
//                               ],
//                               child: Chip(
//                                 label: Text(data['status'] ?? ''),
//                                 backgroundColor: statusColor.withOpacity(0.2),
//                                 labelStyle: TextStyle(color: statusColor),
//                               ),
//                             )
//                                 : Chip(
//                               label: Text(data['status'] ?? ''),
//                               backgroundColor: statusColor.withOpacity(0.2),
//                               labelStyle: TextStyle(color: statusColor),
//                             ),
//                           )
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// Keep your existing imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HelpSeekerHomeScreen extends StatefulWidget {
  const HelpSeekerHomeScreen({super.key});

  @override
  State<HelpSeekerHomeScreen> createState() => _HelpSeekerHomeScreenState();
}

class _HelpSeekerHomeScreenState extends State<HelpSeekerHomeScreen> {

  bool _validateAccompanimentFields() {
    if (_selectedHelpType == 'Accompaniment') {
      if (_selectedDate == null || _selectedTime == null || _destinationController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide date, time, and destination for accompaniment.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false;
      }
    }
    return true;
  }

  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final format = DateFormat.jm(); // e.g., 5:08 PM
    final dt = format.parse(timeString);
    return TimeOfDay.fromDateTime(dt);
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  String _selectedHelpType = 'Food';
  String _selectedUrgency = 'Medium';
  String _selectedStatus = 'All';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final helpTypes = ['Food', 'Medical', 'Shelter', 'Accompaniment'];
  final urgencies = ['High', 'Medium', 'Low'];
  final statusOptions = ['All', 'Pending', 'Accepted', 'Completed'];

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateAccompanimentFields()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;


    await FirebaseFirestore.instance.collection('requests').add({
      'requesterId': user.uid,
      'requesterName': _nameController.text.trim(),
      'requesterPhone': _phoneController.text.trim(),
      'helpType': _selectedHelpType,
      'urgency': _selectedUrgency,
      'location': _locationController.text.trim(),
      'description': _selectedHelpType == 'Accompaniment' ? '' : _descriptionController.text.trim(),
      'destination': _selectedHelpType == 'Accompaniment' ? _destinationController.text.trim() : null,
      'accompanyDate': _selectedHelpType == 'Accompaniment' && _selectedDate != null
          ? Timestamp.fromDate(_selectedDate!)
          : null,
      'accompanyTime': _selectedHelpType == 'Accompaniment' && _selectedTime != null
          ? _selectedTime!.format(context)
          : null,
      'timestamp': Timestamp.now(),
      'status': 'Pending',
      'seenByRequester': true,
      'acceptedBy': null,
      'helpSeekerConfirmed': false,
    });

    _nameController.clear();
    _phoneController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _destinationController.clear();
    _selectedDate = null;
    _selectedTime = null;
    setState(() => _selectedHelpType = 'Food');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("✅ Success"),
        content: const Text("Your request has been submitted successfully!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _editRequest(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    _nameController.text = data['requesterName'] ?? '';
    _phoneController.text = data['requesterPhone'] ?? '';
    _locationController.text = data['location'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _destinationController.text = data['destination'] ?? '';
    _selectedHelpType = data['helpType'] ?? 'Food';
    _selectedUrgency = data['urgency'] ?? 'Medium';

    // Load date and time if available
    _selectedDate = data['accompanyDate'] != null
        ? (data['accompanyDate'] as Timestamp).toDate()
        : null;

    _selectedTime = data['accompanyTime'] != null
        ? _parseTimeOfDay(data['accompanyTime'])
        : null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Request'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Full Name', Icons.person),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                _buildTextField(_locationController, 'Location', Icons.location_on),
                _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
                        (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
                _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
                        (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
                if (_selectedHelpType == 'Accompaniment') ...[
                  _buildTextField(_destinationController, 'Destination', Icons.map),
                  _buildDateTimePicker(),
                ] else
                  _buildTextField(_descriptionController, 'Describe your need', Icons.description),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              if (!_validateAccompanimentFields()) return;

              await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
                'requesterName': _nameController.text.trim(),
                'requesterPhone': _phoneController.text.trim(),
                'location': _locationController.text.trim(),
                'helpType': _selectedHelpType,
                'urgency': _selectedUrgency,
                'description': _selectedHelpType == 'Accompaniment' ? '' : _descriptionController.text.trim(),
                'destination': _selectedHelpType == 'Accompaniment' ? _destinationController.text.trim() : null,
                'accompanyDate': _selectedHelpType == 'Accompaniment' && _selectedDate != null
                    ? Timestamp.fromDate(_selectedDate!)
                    : null,
                'accompanyTime': _selectedHelpType == 'Accompaniment' && _selectedTime != null
                    ? _selectedTime!.format(context)
                    : null,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Request updated!")),
              );
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }


  Future<void> _deleteRequest(DocumentSnapshot doc) async {
    await FirebaseFirestore.instance.collection('requests').doc(doc.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Request deleted.")),
    );
  }


  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: Icon(icon),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, String label, void Function(String) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: Icon(icon),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      children: [
        ListTile(
          title: Text(_selectedDate == null
              ? 'Select Date'
              : DateFormat('yMMMd').format(_selectedDate!)),
          leading: const Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
        ),
        ListTile(
          title: Text(_selectedTime == null
              ? 'Select Time'
              : _selectedTime!.format(context)),
          leading: const Icon(Icons.access_time),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() => _selectedTime = picked);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Query baseQuery = FirebaseFirestore.instance
        .collection('requests')
        .where('requesterId', isEqualTo: user?.uid);
    if (_selectedStatus != 'All') {
      baseQuery = baseQuery.where('status', isEqualTo: _selectedStatus);
    }
    baseQuery = baseQuery.orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help-Seeker Dashboard"),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Full Name', Icons.person),
                      _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                      _buildTextField(_locationController, 'Location', Icons.location_on),
                      _buildDropdown(helpTypes, _selectedHelpType, 'Type of Help',
                              (v) => setState(() => _selectedHelpType = v), Icons.help_outline),
                      _buildDropdown(urgencies, _selectedUrgency, 'Urgency Level',
                              (v) => setState(() => _selectedUrgency = v), Icons.priority_high),
                      if (_selectedHelpType == 'Accompaniment') ...[
                        _buildTextField(_destinationController, 'Destination', Icons.map),
                        _buildDateTimePicker(),
                      ] else
                        _buildTextField(_descriptionController, 'Describe your need', Icons.description),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: submitRequest,
                        icon: const Icon(Icons.send),
                        label: const Text("Submit Request"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDropdown(statusOptions, _selectedStatus, 'Filter by Status',
                    (v) => setState(() => _selectedStatus = v), Icons.filter_alt),
            const SizedBox(height: 12),
            const Text("Your Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: baseQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error loading requests");
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No requests yet.");
                }
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final formattedDate = timestamp != null
                        ? DateFormat('d MMM, h:mm a').format(timestamp.toDate())
                        : 'N/A';

                    final statusColor = data['status'] == 'Pending'
                        ? Colors.orange
                        : data['status'] == 'Accepted'
                        ? Colors.green
                        : Colors.grey;

                    final showNewBadge =
                        data['status'] == 'Accepted' && data['seenByRequester'] == false;

                    if (showNewBadge) {
                      FirebaseFirestore.instance
                          .collection('requests')
                          .doc(doc.id)
                          .update({'seenByRequester': true});
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                data['helpType'] == 'Medical'
                                    ? Icons.medical_services
                                    : data['helpType'] == 'Food'
                                    ? Icons.fastfood
                                    : data['helpType'] == 'Accompaniment'
                                    ? Icons.accessibility
                                    : Icons.home,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text("${data['helpType']} (${data['urgency']})",
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                if (showNewBadge)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text("NEW",
                                        style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (data['helpType'] == 'Accompaniment') ...[
                                  if (data['destination'] != null)
                                    Text("Destination: ${data['destination']}"),
                                  if (data['accompanyDate'] != null)
                                    Text("Date: ${DateFormat('yMMMd').format((data['accompanyDate'] as Timestamp).toDate())}"),
                                  if (data['accompanyTime'] != null)
                                    Text("Time: ${data['accompanyTime']}"),
                                ] else ...[
                                  Text(data['description'] ?? ''),
                                ],
                                Text("Location: ${data['location'] ?? 'N/A'}"),
                                Text("Contact: ${data['requesterPhone'] ?? ''}"),
                                Text("Requested on: $formattedDate",
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                if (data['status'] == 'Accepted' && data['acceptedBy'] != null) ...[
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  Text("Volunteer Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("Name: ${data['acceptedBy']['name'] ?? ''}"),
                                  Text("Phone: ${data['acceptedBy']['phone'] ?? ''}"),
                                  if (data['acceptedBy']['message'] != null && data['acceptedBy']['message'].toString().isNotEmpty)
                                    Text("Message: ${data['acceptedBy']['message']}"),
                                ],
                                if (data['status'] == 'Accepted' && !(data['helpSeekerConfirmed'] ?? false))
                                  TextButton.icon(
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.teal),
                                    label: const Text("Mark as Completed"),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance.collection('requests').doc(doc.id).update({
                                        'status': 'Completed',
                                        'helpSeekerConfirmed': true
                                      });
                                    },
                                  ),
                              ],
                            ),
                            trailing: data['status'] == 'Pending'
                                ? PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editRequest(doc); // unchanged
                                } else if (value == 'delete') {
                                  _deleteRequest(doc); // unchanged
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                              child: Chip(
                                label: Text(data['status'] ?? ''),
                                backgroundColor: statusColor.withOpacity(0.2),
                                labelStyle: TextStyle(color: statusColor),
                              ),
                            )
                                : Chip(
                              label: Text(data['status'] ?? ''),
                              backgroundColor: statusColor.withOpacity(0.2),
                              labelStyle: TextStyle(color: statusColor),
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

// Keep your existing _editRequest() and _deleteRequest()
}



