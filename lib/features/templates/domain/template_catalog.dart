import '../../../core/constants/app_constants.dart';

class ResumeTemplateInfo {
  const ResumeTemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.isPremium,
    required this.thumbnailAsset,
    this.productId,
  });
  final String id, name, description;
  final bool isPremium;
  final String thumbnailAsset;
  final String? productId;
}

class TemplateCatalog {
  static const templates = <ResumeTemplateInfo>[
    ResumeTemplateInfo(
      id: 'modern',
      name: 'Modern',
      description: 'Balanced two-column layout',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/modern.png',
    ),
    ResumeTemplateInfo(
      id: 'minimal',
      name: 'Minimal',
      description: 'Clean ATS-friendly document',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/minimal.png',
    ),
    ResumeTemplateInfo(
      id: 'professional',
      name: 'Professional',
      description: 'Classic business layout',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/professional.png',
    ),
    ResumeTemplateInfo(
      id: 'executive',
      name: 'Executive',
      description: 'Premium leadership profile',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/executive.png',
      productId: AppConstants.productExecutive,
    ),
    ResumeTemplateInfo(
      id: 'signature',
      name: 'Signature',
      description: 'Elegant editorial layout',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/signature.png',
      productId: AppConstants.productSignature,
    ),
    ResumeTemplateInfo(
      id: 'tech',
      name: 'Tech',
      description: 'Modern engineering-focused layout',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/tech.png',
      productId: AppConstants.productTech,
    ),
  ];
  static ResumeTemplateInfo byId(String id) =>
      templates.firstWhere((e) => e.id == id, orElse: () => templates.first);
}
