import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus
import 'dart:io';

void main() {
  runApp(const InNeedApp());
}

class InNeedApp extends StatelessWidget {
  const InNeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'InNeed',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String id;
  final String user;
  final String description;
  final String? imagePath;
  final String? location;
  final String category;
  final List<String> comments;
  final List<String> likes;
  int views; // Make views mutable

  Post({
    required this.id,
    required this.user,
    required this.description,
    this.imagePath,
    this.location,
    required this.category,
    this.comments = const [],
    this.likes = const [],
    this.views = 0, // Initialize views to 0
  });
}

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  String? _selectedLocation;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'General';

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() => _image = pickedFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _selectedLocation = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submitPost(BuildContext context) {
    final post = Post(
      id: DateTime.now().toString(),
      user: 'Current User', // Replace with actual user data
      description: _descriptionController.text,
      imagePath: _image?.path,
      location: _selectedLocation,
      category: _selectedCategory,
    );

    Navigator.pop(context, post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _image == null
                          ? const Center(child: Text('Add Photo'))
                          : Image.file(
                              File(_image!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: ['General', 'Food', 'Clothing', 'Shelter', 'Other']
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Add Location'),
                    subtitle: Text(_selectedLocation ?? 'Not selected'),
                    onTap: _getCurrentLocation,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () => _submitPost(context),
                    child: const Text('Post to Community'),
                  ),
                ],
              ),
            ),
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imagePath != null)
              Image.file(
                File(post.imagePath!),
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            const SizedBox(height: 20),
            Text(
              post.description,
              style: const TextStyle(fontSize: 18),
            ),
            if (post.location != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Location: ${post.location}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              'Category: ${post.category}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up),
                  onPressed: () {
                    // Implement like functionality
                  },
                ),
                Text('${post.likes.length} Likes'),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share('Check out this post: ${post.description}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Views: ${post.views}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Comments:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: post.comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(post.comments[index]),
                  );
                },
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Add a comment',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  post.comments.add(value);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Post> _posts = [];

  void _addPost(Post post) {
    setState(() {
      _posts.add(post);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InNeed')),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(post.description),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.location != null) Text(post.location!),
                  Text('Category: ${post.category}'),
                  Text('Views: ${post.views}'),
                ],
              ),
              leading: post.imagePath != null
                  ? Image.file(
                      File(post.imagePath!),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : null,
              onTap: () {
                setState(() {
                  post.views++; // Increment views
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post: post),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPost = await Navigator.push<Post>(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
          if (newPost != null) {
            _addPost(newPost);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text(
          'Profile Page - Coming Soon!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}