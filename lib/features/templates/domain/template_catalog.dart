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
      thumbnailAsset: 'assets/templates/thumbnails/Template - 2.jpg',
    ),
    ResumeTemplateInfo(
      id: 'minimal',
      name: 'Minimal',
      description: 'Clean ATS-friendly document',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 3.jpg',
    ),
    ResumeTemplateInfo(
      id: 'professional',
      name: 'Professional',
      description: 'Classic business layout',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 1.jpg',
    ),
    ResumeTemplateInfo(
      id: 'classic',
      name: 'Classic',
      description: 'Traditional recruiter-friendly format',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 5.jpg',
    ),
    ResumeTemplateInfo(
      id: 'executive',
      name: 'Executive',
      description: 'Premium leadership profile',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 4.jpg',
      productId: AppConstants.productExecutive,
    ),
    ResumeTemplateInfo(
      id: 'signature',
      name: 'Signature',
      description: 'Elegant editorial layout',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 7.jpg',
      productId: AppConstants.productSignature,
    ),
    ResumeTemplateInfo(
      id: 'tech',
      name: 'Tech',
      description: 'Modern engineering-focused layout',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 6.jpg',
      productId: AppConstants.productTech,
    ),
    ResumeTemplateInfo(
      id: 'creative',
      name: 'Creative',
      description: 'Premium portfolio-style presentation',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 8 Paid.jpg',
      productId: AppConstants.productProPack,
    ),
  ];
  static ResumeTemplateInfo byId(String id) =>
      templates.firstWhere((e) => e.id == id, orElse: () => templates.first);
}
