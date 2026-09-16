import 'dart:convert';

class ContactInfo {
  const ContactInfo({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.website = '',
    this.linkedIn = '',
    this.photoPath,
  });
  final String fullName, jobTitle, email, phone, location, website, linkedIn;
  final String? photoPath;
  ContactInfo copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? website,
    String? linkedIn,
    String? photoPath,
    bool clearPhoto = false,
  }) => ContactInfo(
    fullName: fullName ?? this.fullName,
    jobTitle: jobTitle ?? this.jobTitle,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    location: location ?? this.location,
    website: website ?? this.website,
    linkedIn: linkedIn ?? this.linkedIn,
    photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
  );
  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'jobTitle': jobTitle,
    'email': email,
    'phone': phone,
    'location': location,
    'website': website,
    'linkedIn': linkedIn,
    'photoPath': photoPath,
  };
  factory ContactInfo.fromJson(Map<String, dynamic> j) => ContactInfo(
    fullName: j['fullName'] ?? '',
    jobTitle: j['jobTitle'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'] ?? '',
    location: j['location'] ?? '',
    website: j['website'] ?? '',
    linkedIn: j['linkedIn'] ?? '',
    photoPath: j['photoPath'],
  );
}

class ExperienceItem {
  const ExperienceItem({
    required this.id,
    this.role = '',
    this.company = '',
    this.location = '',
    this.start = '',
    this.end = '',
    this.description = '',
  });
  final String id, role, company, location, start, end, description;
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'company': company,
    'location': location,
    'start': start,
    'end': end,
    'description': description,
  };
  factory ExperienceItem.fromJson(Map<String, dynamic> j) => ExperienceItem(
    id: j['id'],
    role: j['role'] ?? '',
    company: j['company'] ?? '',
    location: j['location'] ?? '',
    start: j['start'] ?? '',
    end: j['end'] ?? '',
    description: j['description'] ?? '',
  );
}

class EducationItem {
  const EducationItem({
    required this.id,
    this.degree = '',
    this.school = '',
    this.start = '',
    this.end = '',
    this.details = '',
  });
  final String id, degree, school, start, end, details;
  Map<String, dynamic> toJson() => {
    'id': id,
    'degree': degree,
    'school': school,
    'start': start,
    'end': end,
    'details': details,
  };
  factory EducationItem.fromJson(Map<String, dynamic> j) => EducationItem(
    id: j['id'],
    degree: j['degree'] ?? '',
    school: j['school'] ?? '',
    start: j['start'] ?? '',
    end: j['end'] ?? '',
    details: j['details'] ?? '',
  );
}

class NamedDetailItem {
  const NamedDetailItem({
    required this.id,
    this.title = '',
    this.subtitle = '',
    this.description = '',
  });
  final String id, title, subtitle, description;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
  };
  factory NamedDetailItem.fromJson(Map<String, dynamic> j) => NamedDetailItem(
    id: j['id'],
    title: j['title'] ?? '',
    subtitle: j['subtitle'] ?? '',
    description: j['description'] ?? '',
  );
}

enum ResumeSectionType {
  summary,
  experience,
  education,
  skills,
  projects,
  certifications,
  achievements,
  languages,
  interests,
  references,
  custom,
}

class ResumeSectionConfig {
  const ResumeSectionConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.enabled,
    required this.order,
  });
  final String id, title;
  final ResumeSectionType type;
  final bool enabled;
  final int order;
  ResumeSectionConfig copyWith({String? title, bool? enabled, int? order}) =>
      ResumeSectionConfig(
        id: id,
        type: type,
        title: title ?? this.title,
        enabled: enabled ?? this.enabled,
        order: order ?? this.order,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'enabled': enabled,
    'order': order,
  };
  factory ResumeSectionConfig.fromJson(Map<String, dynamic> j) =>
      ResumeSectionConfig(
        id: j['id'],
        type: ResumeSectionType.values.byName(j['type']),
        title: j['title'],
        enabled: j['enabled'] ?? true,
        order: j['order'] ?? 0,
      );
}

class ResumeDocument {
  const ResumeDocument({
    required this.id,
    required this.title,
    required this.contact,
    required this.summary,
    required this.experiences,
    required this.education,
    required this.skills,
    required this.projects,
    required this.certifications,
    required this.achievements,
    required this.languages,
    required this.interests,
    required this.references,
    required this.customSections,
    required this.sections,
    required this.templateId,
    required this.accentColor,
    required this.templateFontScale,
    required this.showPhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.isDirty,
  });
  final String id, title, summary, templateId, accentColor;
  final ContactInfo contact;
  final List<ExperienceItem> experiences;
  final List<EducationItem> education;
  final List<String> skills, languages, interests, references;
  final List<NamedDetailItem> projects, certifications, achievements;
  final Map<String, List<NamedDetailItem>> customSections;
  final List<ResumeSectionConfig> sections;
  final double templateFontScale;
  final bool showPhoto;
  final DateTime createdAt, updatedAt;
  final bool isDirty;

  static List<ResumeSectionConfig> defaultSections() => [
    const ResumeSectionConfig(
      id: 'summary',
      type: ResumeSectionType.summary,
      title: 'Professional Summary',
      enabled: true,
      order: 0,
    ),
    const ResumeSectionConfig(
      id: 'experience',
      type: ResumeSectionType.experience,
      title: 'Work Experience',
      enabled: true,
      order: 1,
    ),
    const ResumeSectionConfig(
      id: 'education',
      type: ResumeSectionType.education,
      title: 'Education',
      enabled: true,
      order: 2,
    ),
    const ResumeSectionConfig(
      id: 'skills',
      type: ResumeSectionType.skills,
      title: 'Skills',
      enabled: true,
      order: 3,
    ),
    const ResumeSectionConfig(
      id: 'projects',
      type: ResumeSectionType.projects,
      title: 'Projects',
      enabled: true,
      order: 4,
    ),
    const ResumeSectionConfig(
      id: 'certifications',
      type: ResumeSectionType.certifications,
      title: 'Certifications',
      enabled: true,
      order: 5,
    ),
    const ResumeSectionConfig(
      id: 'achievements',
      type: ResumeSectionType.achievements,
      title: 'Achievements',
      enabled: false,
      order: 6,
    ),
    const ResumeSectionConfig(
      id: 'languages',
      type: ResumeSectionType.languages,
      title: 'Languages',
      enabled: true,
      order: 7,
    ),
    const ResumeSectionConfig(
      id: 'interests',
      type: ResumeSectionType.interests,
      title: 'Interests',
      enabled: false,
      order: 8,
    ),
    const ResumeSectionConfig(
      id: 'references',
      type: ResumeSectionType.references,
      title: 'References',
      enabled: false,
      order: 9,
    ),
  ];

  factory ResumeDocument.empty(String id) => ResumeDocument(
    id: id,
    title: 'Untitled Resume',
    contact: const ContactInfo(),
    summary: '',
    experiences: const [],
    education: const [],
    skills: const [],
    projects: const [],
    certifications: const [],
    achievements: const [],
    languages: const [],
    interests: const [],
    references: const [],
    customSections: const {},
    sections: defaultSections(),
    templateId: 'modern',
    accentColor: '#2563EB',
    templateFontScale: 1,
    showPhoto: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isDirty: true,
  );

  ResumeDocument copyWith({
    String? title,
    ContactInfo? contact,
    String? summary,
    List<ExperienceItem>? experiences,
    List<EducationItem>? education,
    List<String>? skills,
    List<NamedDetailItem>? projects,
    List<NamedDetailItem>? certifications,
    List<NamedDetailItem>? achievements,
    List<String>? languages,
    List<String>? interests,
    List<String>? references,
    Map<String, List<NamedDetailItem>>? customSections,
    List<ResumeSectionConfig>? sections,
    String? templateId,
    String? accentColor,
    double? templateFontScale,
    bool? showPhoto,
    DateTime? updatedAt,
    bool? isDirty,
  }) => ResumeDocument(
    id: id,
    title: title ?? this.title,
    contact: contact ?? this.contact,
    summary: summary ?? this.summary,
    experiences: experiences ?? this.experiences,
    education: education ?? this.education,
    skills: skills ?? this.skills,
    projects: projects ?? this.projects,
    certifications: certifications ?? this.certifications,
    achievements: achievements ?? this.achievements,
    languages: languages ?? this.languages,
    interests: interests ?? this.interests,
    references: references ?? this.references,
    customSections: customSections ?? this.customSections,
    sections: sections ?? this.sections,
    templateId: templateId ?? this.templateId,
    accentColor: accentColor ?? this.accentColor,
    templateFontScale: templateFontScale ?? this.templateFontScale,
    showPhoto: showPhoto ?? this.showPhoto,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    isDirty: isDirty ?? this.isDirty,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'contact': contact.toJson(),
    'summary': summary,
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'education': education.map((e) => e.toJson()).toList(),
    'skills': skills,
    'projects': projects.map((e) => e.toJson()).toList(),
    'certifications': certifications.map((e) => e.toJson()).toList(),
    'achievements': achievements.map((e) => e.toJson()).toList(),
    'languages': languages,
    'interests': interests,
    'references': references,
    'customSections': customSections.map(
      (k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()),
    ),
    'sections': sections.map((e) => e.toJson()).toList(),
    'templateId': templateId,
    'accentColor': accentColor,
    'templateFontScale': templateFontScale,
    'showPhoto': showPhoto,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isDirty': isDirty,
  };
  factory ResumeDocument.fromJson(Map<String, dynamic> j) => ResumeDocument(
    id: j['id'],
    title: j['title'] ?? 'Resume',
    contact: ContactInfo.fromJson(
      Map<String, dynamic>.from(j['contact'] ?? {}),
    ),
    summary: j['summary'] ?? '',
    experiences: (j['experiences'] as List? ?? [])
        .map((e) => ExperienceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    education: (j['education'] as List? ?? [])
        .map((e) => EducationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    skills: List<String>.from(j['skills'] ?? []),
    projects: (j['projects'] as List? ?? [])
        .map((e) => NamedDetailItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    certifications: (j['certifications'] as List? ?? [])
        .map((e) => NamedDetailItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    achievements: (j['achievements'] as List? ?? [])
        .map((e) => NamedDetailItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    languages: List<String>.from(j['languages'] ?? []),
    interests: List<String>.from(j['interests'] ?? []),
    references: List<String>.from(j['references'] ?? []),
    customSections: (j['customSections'] as Map? ?? {}).map(
      (k, v) => MapEntry(
        k.toString(),
        (v as List)
            .map((e) => NamedDetailItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      ),
    ),
    sections: (j['sections'] as List? ?? [])
        .map((e) => ResumeSectionConfig.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    templateId: j['templateId'] ?? 'modern',
    accentColor: j['accentColor'] ?? '#2563EB',
    templateFontScale: (j['templateFontScale'] as num? ?? 1).toDouble(),
    showPhoto: j['showPhoto'] ?? true,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
    isDirty: j['isDirty'] ?? false,
  );
  String encode() => jsonEncode(toJson());
  static ResumeDocument decode(String raw) =>
      ResumeDocument.fromJson(jsonDecode(raw));
}
