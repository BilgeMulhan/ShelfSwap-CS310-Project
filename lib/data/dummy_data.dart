import '../models/listing_item.dart';
import '../models/request_item.dart';
import '../models/user_profile.dart';

class DummyData {
  static List<ListingItem> latestListings = [
    ListingItem(
      title: 'Headphones',
      condition: 'Used',
      location: 'Campus Dorm',
      imageUrl: 'assets/images/Headphones.png',
    ),
    ListingItem(
      title: 'Reading Book',
      condition: 'New',
      location: 'Library Area',
      imageUrl: 'assets/images/ReadingBook.png',
    ),
    ListingItem(
      title: 'Calculus Book',
      condition: 'Used',
      location: 'Sabanci University',
      imageUrl: 'assets/images/CalculusBook.png',
    ),
    ListingItem(
      title: 'Vintage Lamp',
      condition: 'Good',
      location: 'Faculty Office',
      imageUrl: 'assets/images/VintageLamp.png',
    ),
  ];

  static List<RequestItem> requests = [
    RequestItem(
      sender: 'Ahmet Y.',
      itemTitle: 'Calculus Book',
      location: 'Campus Dorm',
      time: '1h ago',
    ),
    RequestItem(
      sender: 'Mustafa',
      itemTitle: 'Vintage Lamp',
      location: 'Main Building',
      time: '2d ago',
    ),
  ];

  static UserProfile user = UserProfile(
    name: 'Asli Koca',
    email: 'asli.koca@sabanciuniv.edu',
    bio: 'Senior CS student at Sabanci University',
  );
}