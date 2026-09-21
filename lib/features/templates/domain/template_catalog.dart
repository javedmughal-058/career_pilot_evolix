import '../../../core/constants/app_constants.dart';

class ResumeTemplateInfo {
  const ResumeTemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.isPremium,
    required this.thumbnailAsset,
    required this.defaultAccent,
    this.isAvailable = true,
    this.productId,
  });
  final String id, name, description;
  final bool isPremium;
  final String thumbnailAsset;
  final String defaultAccent;
  final bool isAvailable;
  final String? productId;
}

class TemplateCatalog {
  static const templates = <ResumeTemplateInfo>[
    ResumeTemplateInfo(
      id: 'classic',
      name: 'Classic',
      description: 'Traditional recruiter-friendly format',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 5.jpg',
      defaultAccent: '#0C5066',
    ),
    ResumeTemplateInfo(
      id: 'minimal',
      name: 'Minimal',
      description: 'Clean ATS-friendly document',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 3.jpg',
      defaultAccent: '#092049',
    ),
    ResumeTemplateInfo(
      id: 'modern',
      name: 'Modern',
      description: 'Balanced two-column layout',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 2.jpg',
      defaultAccent: '#0F4C81',
      isAvailable: false,
    ),
    ResumeTemplateInfo(
      id: 'professional',
      name: 'Professional',
      description: 'Classic business layout',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 1.jpg',
      defaultAccent: '#0B3B69',
      isAvailable: false,
    ),

    ResumeTemplateInfo(
      id: 'executive',
      name: 'Executive',
      description: 'Premium leadership profile',
      isPremium: false,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 4.jpg',
      defaultAccent: '#B68A2E',
      isAvailable: false,
      productId: AppConstants.productExecutive,
    ),
    ResumeTemplateInfo(
      id: 'tech',
      name: 'Tech',
      description: 'Modern engineering-focused layout',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 6.jpg',
      defaultAccent: '#0C9EA0',
      isAvailable: true,
      productId: AppConstants.productTech,
    ),
    ResumeTemplateInfo(
      id: 'signature',
      name: 'Signature',
      description: 'Elegant editorial layout',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 7.jpg',
      defaultAccent: '#C98383',
      isAvailable: false,
      productId: AppConstants.productSignature,
    ),
    ResumeTemplateInfo(
      id: 'creative',
      name: 'Creative',
      description: 'Premium portfolio-style presentation',
      isPremium: true,
      thumbnailAsset: 'assets/templates/thumbnails/Template - 8 Paid.jpg',
      defaultAccent: '#5B5BEA',
      isAvailable: false,
      productId: AppConstants.productProPack,
    ),
  ];
  static ResumeTemplateInfo byId(String id) =>
      templates.firstWhere((e) => e.id == id, orElse: () => templates.first);
}
