import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../models/portfolio_model.dart';
import '../controllers/portfolio_controller.dart';

class CvTemplatesView extends StatelessWidget {
  final PortfolioController _controller = Get.find<PortfolioController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CV Templates'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _exportToPdf(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Template selection
          _buildTemplateSelector(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                switch (_controller.selectedTemplate.value) {
                  case 'Template 1':
                    return _buildTemplate1();
                  case 'Template 2':
                    return _buildTemplate2();
                  case 'Template 3':
                    return _buildTemplate3();
                  case 'Template 4':
                    return _buildTemplate4();
                  default:
                    return _buildTemplate1();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _templateButton('Template 1', '1'),
          _templateButton('Template 2', '2'),
          _templateButton('Template 3', '3'),
          _templateButton('Template 4', '4'),
        ],
      ),
    );
  }

  Widget _templateButton(String templateName, String label) {
    return Obx(() => ElevatedButton(
          onPressed: () => _controller.selectedTemplate.value = templateName,
          style: ElevatedButton.styleFrom(
            backgroundColor: _controller.selectedTemplate.value == templateName
                ? Colors.blue
                : Colors.grey,
          ),
          child: Text(label),
        ));
  }

  // Template 1: Modern Professional
  Widget _buildTemplate1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          SizedBox(height: 16),
          // Education
          _buildEducationSection(),
          SizedBox(height: 16),
          // Experience
          _buildExperienceSection(),
          SizedBox(height: 16),
          // Skills
          _buildSkillsSection(),
        ],
      ),
    );
  }

  // Template 2: Creative
  Widget _buildTemplate2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creative header with different layout
          _buildCreativeHeader(),
          SizedBox(height: 16),
          // Two-column layout for experience and education
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEducationSection(compact: true),
                    SizedBox(height: 16),
                    _buildSkillsSection(compact: true),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildExperienceSection(compact: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Template 3: Minimalist
  Widget _buildTemplate3() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimalist header
          _buildMinimalistHeader(),
          Divider(),
          // Education
          _buildEducationSection(minimalist: true),
          Divider(),
          // Experience
          _buildExperienceSection(minimalist: true),
          Divider(),
          // Skills
          _buildSkillsSection(minimalist: true),
        ],
      ),
    );
  }

  // Template 4: Sophia Harper Style (based on the image)
  Widget _buildTemplate4() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and title centered
          Center(
            child: Column(
              children: [
                Text(
                  'SOPHIA HARPER',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Interior Designer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          
          // Contact information in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('Mob: +123-456-7890'),
                  Text('Email: sophia_harper@floremipsum.com'),
                ],
              ),
              Column(
                children: [
                  Text('Portfolio: www.loremipsum.com'),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Sections with horizontal lines
          _buildSophiaSection('EDUCATION', _buildSophiaEducation()),
          _buildSophiaSection('ABOUT', _buildSophiaAbout()),
          _buildSophiaSection('WORK EXPERIENCE', _buildSophiaExperience()),
          _buildSophiaSection('EXPERTISE', _buildSophiaExpertise()),
          _buildSophiaSection('SOFTWARE', _buildSophiaSoftware()),
          _buildSophiaSection('REFERENCES', _buildSophiaReferences()),
        ],
      ),
    );
  }

  Widget _buildSophiaSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Divider(),
        content,
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSophiaEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSophiaEducationItem(
          'BA Interior Design',
          'Wheaton University',
          '2006 – 2008'
        ),
        SizedBox(height: 8),
        _buildSophiaEducationItem(
          'BA Interior Architecture',
          'Brockenhurst University',
          '2006 – 2008'
        ),
      ],
    );
  }

  Widget _buildSophiaEducationItem(String degree, String university, String years) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          degree,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(university),
        Text(years),
      ],
    );
  }

  Widget _buildSophiaAbout() {
    return Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildSophiaExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSophiaExperienceItem(
          'KARO design studio',
          'Senior Interior Designer',
          [
            'Working with the creative director & CEO.',
            'Team management.',
            'Creative brief building.',
            'Overseeing projects from initial stages through to completion.',
            'Creating brand guidelines.',
          ]
        ),
        SizedBox(height: 16),
        _buildSophiaExperienceItem(
          'Lorem Ipsum',
          'Midweight Interior Designer',
          [
            'Producing 2D & 3D drawing packages.',
            'Design management of projects.',
            'Working as part of creative team.',
          ]
        ),
        SizedBox(height: 16),
        _buildSophiaExperienceItem(
          'Lorem Ipsum',
          'Junior Interior Designer',
          [
            'Working with the wider development team.',
            'Supporting senior and middleweight designers with furniture drawings.',
          ]
        ),
      ],
    );
  }

  Widget _buildSophiaExperienceItem(String company, String position, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          company,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(position),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: points.map((point) => Text('• $point')).toList(),
        ),
      ],
    );
  }

  Widget _buildSophiaExpertise() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        'Management Skills',
        'Interior Design',
        '2D & 3D Design',
        'Creative Thinking',
        'Urban design',
        'Team Work',
      ].map((skill) => Chip(label: Text(skill))).toList(),
    );
  }

  Widget _buildSophiaSoftware() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        'AutoCAD',
        'Adobe Suit',
        '3D Max',
        'Google Docs',
      ].map((software) => Chip(label: Text(software))).toList(),
    );
  }

  Widget _buildSophiaReferences() {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            Text('K Smith'),
            Text('Lorem Ipsum'),
          ],
        ),
        TableRow(
          children: [
            Text('KARO design studio'),
            Text('Ipsum Inc.'),
          ],
        ),
        TableRow(
          children: [
            Text('Phone: 123-456-7890'),
            Text('Phone: 123-456-7890'),
          ],
        ),
        TableRow(
          children: [
            Text('Email: hello@fkarodesignstud.com'),
            Text('Email: hello@floremipsum.com'),
          ],
        ),
      ],
    );
  }

  // Common components for templates
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'John Doe', // Replace with actual user name
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Software Developer', // Replace with actual user title
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        Text('email@example.com | +1234567890 | portfolio.com'),
      ],
    );
  }

  Widget _buildCreativeHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            // Add user image if available
            child: Icon(Icons.person, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('Software Developer'),
                SizedBox(height: 4),
                Text('email@example.com | +1234567890'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JOHN DOE',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text('Software Developer'),
        SizedBox(height: 4),
        Text('email@example.com | +1234567890 | portfolio.com'),
      ],
    );
  }

  Widget _buildEducationSection({bool compact = false, bool minimalist = false}) {
    if (_controller.education.isEmpty) {
      return Text('No education information added yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EDUCATION',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ..._controller.education.map((education) => 
          _buildEducationItem(education, compact: compact, minimalist: minimalist)
        ).toList(),
      ],
    );
  }

  Widget _buildEducationItem(EducationModel education, {bool compact = false, bool minimalist = false}) {
    if (minimalist) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            education.degree,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(education.institution),
          Text('${_formatDate(education.startDate)} - ${education.isCurrent ? 'Present' : _formatDate(education.endDate!)}'),
          SizedBox(height: 8),
        ],
      );
    }
    
    return ListTile(
      contentPadding: compact ? EdgeInsets.zero : null,
      title: Text(
        education.degree,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(education.institution),
          Text('${_formatDate(education.startDate)} - ${education.isCurrent ? 'Present' : _formatDate(education.endDate!)}'),
          if (education.description != null && education.description!.isNotEmpty)
            Text(education.description!),
        ],
      ),
    );
  }

  Widget _buildExperienceSection({bool compact = false, bool minimalist = false}) {
    if (_controller.experience.isEmpty) {
      return Text('No experience information added yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPERIENCE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ..._controller.experience.map((experience) => 
          _buildExperienceItem(experience, compact: compact, minimalist: minimalist)
        ).toList(),
      ],
    );
  }

  Widget _buildExperienceItem(ExperienceModel experience, {bool compact = false, bool minimalist = false}) {
    if (minimalist) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience.position,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(experience.company),
          Text('${_formatDate(experience.startDate)} - ${experience.isCurrent ? 'Present' : _formatDate(experience.endDate!)}'),
          if (experience.description != null && experience.description!.isNotEmpty)
            Text(experience.description!),
          SizedBox(height: 8),
        ],
      );
    }
    
    return ListTile(
      contentPadding: compact ? EdgeInsets.zero : null,
      title: Text(
        experience.position,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(experience.company),
          Text('${_formatDate(experience.startDate)} - ${experience.isCurrent ? 'Present' : _formatDate(experience.endDate!)}'),
          if (experience.description != null && experience.description!.isNotEmpty)
            Text(experience.description!),
        ],
      ),
    );
  }

  Widget _buildSkillsSection({bool compact = false, bool minimalist = false}) {
    if (_controller.skills.isEmpty) {
      return Text('No skills information added yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        minimalist 
          ? Text(_controller.skills.map((skill) => skill.name).join(', '))
          : Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _controller.skills
                  .map((skill) => Chip(label: Text(skill.name)))
                  .toList(),
            ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}';
  }

  Future<void> _exportToPdf(BuildContext context) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page based on the selected template
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPdfContent();
          },
        ),
      );

      // Save the document
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/cv.pdf");
      await file.writeAsBytes(await pdf.save());

      // Share or open the PDF
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'cv.pdf');
      
      Get.snackbar('Success', 'CV exported to PDF successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to export PDF: $e');
    }
  }

  pw.Widget _buildPdfContent() {
    // This would build the PDF content based on the selected template
    // Similar to the widget builders but using pdf widgets
    return pw.Center(
      child: pw.Text('CV PDF Content'),
    );
  }
}