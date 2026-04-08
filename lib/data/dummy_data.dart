import '../models/listing_item.dart';
import '../models/request_item.dart';
import '../models/user_profile.dart';

class DummyData {
  static List<ListingItem> latestListings = [
    ListingItem(
      title: 'Headphones',
      condition: 'Used',
      location: 'Campus Dorm',
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
    ),
    ListingItem(
      title: 'Reading Book',
      condition: 'New',
      location: 'Library Area',
      imageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794',
    ),
    ListingItem(
      title: 'Calculus Book',
      condition: 'Used',
      location: 'Sabanci University',
      imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f',
    ),
    ListingItem(
      title: 'Vintage Lamp',
      condition: 'Good',
      location: 'Faculty Office',
      imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c',
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