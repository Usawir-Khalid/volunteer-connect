/// Opportunity model for mock data.
class Opportunity {
  final String id;
  final String title;
  final String organization;
  final String location;
  final DateTime dateTime;
  final String dateDisplay;
  final String timeDisplay;
  final double distance;
  final String category;
  final String description;
  final String availability;
  final String imageUrl;

  Opportunity({
    required this.id,
    required this.title,
    required this.organization,
    required this.location,
    required this.dateTime,
    required this.dateDisplay,
    required this.timeDisplay,
    required this.distance,
    required this.category,
    required this.description,
    required this.availability,
    required this.imageUrl,
  });

  static String _formatDateForDisplay(DateTime dateTime) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final dayOfWeek = days[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];

    return '$dayOfWeek, $month ${dateTime.day}';
  }

  static List<Opportunity> mockOpportunities() {
    final now = DateTime.now();

    final date1 = now.add(const Duration(days: 2));
    final date2 = now.add(const Duration(days: 3));
    final date3 = now.add(const Duration(days: 6));
    final date4 = now.add(const Duration(days: 4));
    final date5 = now.add(const Duration(days: 5));
    final date6 = now.add(const Duration(days: 10));
    final date7 = now.add(const Duration(days: 7));
    final date8 = now.add(const Duration(days: 15));

    return [
      Opportunity(
        id: '1',
        title: 'Community Clean-Up',
        organization: 'Green Earth Alliance',
        location: 'Central Park',
        dateTime: date1,
        dateDisplay: _formatDateForDisplay(date1),
        timeDisplay: '9:00 AM',
        distance: 1.2,
        category: 'Environment',
        description:
            'Help us keep our community clean and green. Join us for a morning of picking up litter and beautifying our local parks.',
        availability: 'Limited spots',
        imageUrl:
            'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=800',
      ),
      Opportunity(
        id: '2',
        title: 'Tree Planting Initiative',
        organization: 'Green Earth',
        location: 'Golden Gate Park',
        dateTime: date2,
        dateDisplay: _formatDateForDisplay(date2),
        timeDisplay: '10:00 AM',
        distance: 2.4,
        category: 'Environment',
        description:
            'Plant native trees to restore our urban forest. No experience necessary—we provide all tools and training.',
        availability: 'Open',
        imageUrl:
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
      ),
      Opportunity(
        id: '3',
        title: 'Food Bank Sorting',
        organization: 'City Harvest',
        location: 'Community Food Center',
        dateTime: date3,
        dateDisplay: _formatDateForDisplay(date3),
        timeDisplay: '2:00 PM',
        distance: 2.5,
        category: 'Community',
        description:
            'Sort, pack, and distribute food to families in need. This vital work directly impacts our community.',
        availability: 'Multiple shifts',
        imageUrl:
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
      ),
      Opportunity(
        id: '4',
        title: 'Reading Program',
        organization: 'Bright Futures',
        location: 'Lincoln Community Center',
        dateTime: date4,
        dateDisplay: _formatDateForDisplay(date4),
        timeDisplay: '4:00 PM',
        distance: 3.1,
        category: 'Education',
        description:
            'Tutor children in reading and literacy. Make a lasting difference in a young learner\'s life.',
        availability: 'Open',
        imageUrl:
            'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
      ),
      Opportunity(
        id: '5',
        title: 'Community Health Drive',
        organization: 'Health for All',
        location: 'Civic Center',
        dateTime: date5,
        dateDisplay: _formatDateForDisplay(date5),
        timeDisplay: '11:00 AM',
        distance: 4.2,
        category: 'Healthcare',
        description:
            'Support a local community health initiative by helping with registration, coordination, and outreach.',
        availability: 'Limited spots',
        imageUrl:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      ),
      Opportunity(
        id: '6',
        title: 'Senior Support Program',
        organization: 'Community Care',
        location: 'Westside Community Center',
        dateTime: date6,
        dateDisplay: _formatDateForDisplay(date6),
        timeDisplay: '1:00 PM',
        distance: 5.6,
        category: 'Community',
        description:
            'Spend time with seniors in the community and help with social activities and basic support.',
        availability: 'Open',
        imageUrl:
            'https://images.unsplash.com/photo-1559234938-b60fff04894d?w=800',
      ),
      Opportunity(
        id: '7',
        title: 'Youth Sports Volunteer',
        organization: 'Active Youth',
        location: 'Mission Sports Center',
        dateTime: date7,
        dateDisplay: _formatDateForDisplay(date7),
        timeDisplay: '3:00 PM',
        distance: 6.8,
        category: 'Community',
        description:
            'Help organize youth sports activities and encourage children to stay active and engaged.',
        availability: 'Open',
        imageUrl:
            'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
      ),
      Opportunity(
        id: '8',
        title: 'Food Distribution',
        organization: 'Helping Hands',
        location: 'Eastside Food Center',
        dateTime: date8,
        dateDisplay: _formatDateForDisplay(date8),
        timeDisplay: '10:00 AM',
        distance: 9.2,
        category: 'Community',
        description:
            'Help distribute essential food supplies to families and individuals in need.',
        availability: 'Multiple shifts',
        imageUrl:
            'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800',
      ),
    ];
  }
}