import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/validators.dart';
import '../../models/incident.dart';
import '../../models/incident_enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/ui.dart';
import '../../widgets/app_button.dart';

/// Create a new report, or edit one that is still "submitted".
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key, this.editing});
  final Incident? editing;

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.editing?.title);
  late final _desc = TextEditingController(text: widget.editing?.description);
  final _picker = ImagePicker();

  late IncidentCategory? _category = widget.editing?.category;
  late String? _location = _initialLocation();
  late final _detail = TextEditingController(text: _initialDetail());
  late bool _anonymous = widget.editing?.isAnonymous ?? false;
  File? _photo;
  bool _categoryError = false;

  bool get _isEdit => widget.editing != null;

  String? _initialLocation() {
    final loc = widget.editing?.location;
    if (loc == null) return null;
    return AppConfig.campusLocations
        .where((l) => loc == l || loc.startsWith('$l — '))
        .firstOrNull;
  }

  String _initialDetail() {
    final loc = widget.editing?.location;
    if (loc == null || !loc.contains(' — ')) return '';
    return loc.split(' — ').skip(1).join(' — ');
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
          source: source, imageQuality: 70, maxWidth: 1600);
      if (x != null) setState(() => _photo = File(x.path));
    } catch (_) {
      if (mounted) showSnack(context, 'Could not open the camera or gallery.', error: true);
    }
  }

  void _photoSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(ctx);
              _pick(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _pick(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _categoryError = _category == null);
    if (!_form.currentState!.validate() || _category == null) return;

    final detail = _detail.text.trim();
    final location = detail.isEmpty ? _location! : '$_location — $detail';
    final auth = context.read<AuthProvider>();
    final provider = context.read<IncidentProvider>();

    final err = _isEdit
        ? await provider.edit(widget.editing!,
            title: _title.text,
            description: _desc.text,
            category: _category!,
            location: location,
            anonymous: _anonymous)
        : await provider.submit(
            uid: auth.user!.uid,
            name: auth.profile?.name ?? 'Student',
            title: _title.text,
            description: _desc.text,
            category: _category!,
            location: location,
            anonymous: _anonymous,
            photo: _photo);

    if (!mounted) return;
    if (err != null) {
      showSnack(context, err, error: true);
    } else {
      Navigator.of(context).pop(true);
      showSnack(context, _isEdit ? 'Report updated' : 'Report submitted. Thank you!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<IncidentProvider>().submitting;
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit report' : 'Report an issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Category', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in IncidentCategory.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    selected: _category == c,
                    showCheckmark: false,
                    selectedColor: AppColors.pine.withValues(alpha: 0.14),
                    onSelected: (_) => setState(() {
                      _category = c;
                      _categoryError = false;
                    }),
                  ),
              ]),
              if (_categoryError)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Choose a category',
                      style: TextStyle(color: AppColors.urgent, fontSize: 12)),
                ),
              if (_category == IncidentCategory.safety)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.urgent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Safety reports are flagged as urgent for staff. In an emergency, '
                    'contact campus security directly.',
                    style: TextStyle(color: AppColors.urgent, fontSize: 12.5),
                  ),
                ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _title,
                maxLength: 80,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Title', hintText: 'Briefly describe the issue'),
                validator: (v) => Validators.minLength(v, 5, 'Title'),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _desc,
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What happened, when, and who is affected?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validators.minLength(v, 15, 'Description'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: const InputDecoration(
                    labelText: 'Location', prefixIcon: Icon(Icons.place_outlined)),
                items: [
                  for (final l in AppConfig.campusLocations)
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _location = v),
                validator: (v) => v == null ? 'Choose a location' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _detail,
                decoration: const InputDecoration(
                    labelText: 'Room or spot (optional)', hintText: 'e.g. Block B, Room 204'),
              ),
              const SizedBox(height: 18),
              Text('Photo (optional)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _photoBox(),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.pine,
                title: const Text('Hide my name from other students'),
                subtitle: const Text('Staff can still see who reported it.'),
                value: _anonymous,
                onChanged: (v) => setState(() => _anonymous = v),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: _isEdit ? 'Save changes' : 'Submit report',
                icon: _isEdit ? Icons.check : Icons.send_outlined,
                loading: submitting,
                onPressed: _submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _photoBox() {
    if (_isEdit) {
      final url = widget.editing!.photoUrl;
      return url == null
          ? const Text('No photo attached.', style: TextStyle(color: AppColors.slate))
          : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                  imageUrl: url, height: 140, width: double.infinity, fit: BoxFit.cover));
    }
    if (_photo != null) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(_photo!, height: 180, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filled(
            style: IconButton.styleFrom(backgroundColor: AppColors.ink),
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _photo = null),
          ),
        ),
      ]);
    }
    return InkWell(
      onTap: _photoSheet,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 96,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.stone),
        ),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_a_photo_outlined, color: AppColors.slate),
          SizedBox(height: 6),
          Text('Tap to add a photo', style: TextStyle(color: AppColors.slate)),
        ]),
      ),
    );
  }
}