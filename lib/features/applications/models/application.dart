enum ApplicationStatus {
  pending,
  accepted,
  completed,
  rejected,
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.completed:
        return 'Completed';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}

class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.title,
    required this.organization,
    required this.category,
    required this.location,
    required this.dateTime,
    required this.status,
    required this.submittedDate,
    required this.description,
  });

  final String id;
  final String opportunityId;
  final String title;
  final String organization;
  final String category;
  final String location;
  final DateTime dateTime;
  final ApplicationStatus status;
  final DateTime submittedDate;
  final String description;

  static List<Application> mockApplications() {
    final now = DateTime.now();

    return [
      Application(
        id: 'application_1',
        opportunityId: '1',
        title: 'Community Clean-Up',
        organization: 'Green Earth Alliance',
        category: 'Environment',
        location: 'Central Park',
        dateTime: now.add(
          const Duration(days: 2),
        ),
        status: ApplicationStatus.accepted,
        submittedDate: now.subtract(
          const Duration(days: 8),
        ),
        description:
            'Help keep the local community clean and welcoming. '
            'Volunteers will work together to collect litter, '
            'organize recyclable materials, and improve shared '
            'public spaces.',
      ),
      Application(
        id: 'application_2',
        opportunityId: '3',
        title: 'Food Bank Sorting',
        organization: 'City Harvest',
        category: 'Community',
        location: 'Community Food Center',
        dateTime: now.add(
          const Duration(days: 6),
        ),
        status: ApplicationStatus.pending,
        submittedDate: now.subtract(
          const Duration(days: 2),
        ),
        description:
            'Help sort, pack, and organize food donations for '
            'families and individuals in need within the local '
            'community.',
      ),
      Application(
        id: 'application_3',
        opportunityId: '4',
        title: 'Reading Program',
        organization: 'Bright Futures',
        category: 'Education',
        location: 'Lincoln Community Center',
        dateTime: now.add(
          const Duration(days: 4),
        ),
        status: ApplicationStatus.pending,
        submittedDate: now.subtract(
          const Duration(days: 1),
        ),
        description:
            'Support children with reading and literacy activities '
            'through one-on-one and small group sessions.',
      ),
      Application(
        id: 'application_4',
        opportunityId: '5',
        title: 'Community Health Drive',
        organization: 'Health for All',
        category: 'Healthcare',
        location: 'Civic Center',
        dateTime: now.add(
          const Duration(days: 10),
        ),
        status: ApplicationStatus.rejected,
        submittedDate: now.subtract(
          const Duration(days: 14),
        ),
        description:
            'Support a local health initiative by helping with '
            'registration, coordination, and community outreach.',
      ),
      Application(
        id: 'application_5',
        opportunityId: '6',
        title: 'Senior Support Program',
        organization: 'Community Care',
        category: 'Community',
        location: 'Westside Community Center',
        dateTime: now.subtract(
          const Duration(days: 15),
        ),
        status: ApplicationStatus.completed,
        submittedDate: now.subtract(
          const Duration(days: 35),
        ),
        description:
            'Spend meaningful time with seniors and assist with '
            'social activities, conversations, and community events.',
      ),
      Application(
        id: 'application_6',
        opportunityId: '7',
        title: 'Youth Sports Volunteer',
        organization: 'Active Youth',
        category: 'Community',
        location: 'Mission Sports Center',
        dateTime: now.add(
          const Duration(days: 7),
        ),
        status: ApplicationStatus.accepted,
        submittedDate: now.subtract(
          const Duration(days: 5),
        ),
        description:
            'Help organize youth sports activities and create a '
            'positive, welcoming environment for young participants.',
      ),
    ];
  }
} 