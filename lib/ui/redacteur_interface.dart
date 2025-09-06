import 'package:flutter/material.dart';
import '../database/database_manager.dart';
import '../modele/redacteur.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isEditing = false;
  int? _editingId;

  List<Redacteur> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final data = await DatabaseManager.instance.getAll();
    if (!mounted) return;
    setState(() => _items = data);
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Email requis";
    final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(v.trim());
    return ok ? null : "Email invalide";
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nomCtrl.clear();
    _prenomCtrl.clear();
    _emailCtrl.clear();
    setState(() {
      _isEditing = false;
      _editingId = null;
    });
  }

  Future<void> _addOrUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final r = Redacteur(
      id: _editingId,
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    try {
      if (_isEditing) {
        await DatabaseManager.instance.update(r);
        setState(() {
          final index = _items.indexWhere((el) => el.id == r.id);
          if (index != -1) _items[index] = r;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Rédacteur modifié")));
      } else {
        final id = await DatabaseManager.instance.insert(r);
        setState(() {
          _items.add(r.copyWith(id: id)); // ✅ ajout immédiat
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Rédacteur ajouté")));
      }
      _resetForm();
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('UNIQUE')
          ? "Cet email existe déjà."
          : "Erreur: ${e.toString()}";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _delete(int id) async {
    await DatabaseManager.instance.delete(id);
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Rédacteur supprimé")));
  }

  void _startEdit(Redacteur r) {
    _nomCtrl.text = r.nom;
    _prenomCtrl.text = r.prenom;
    _emailCtrl.text = r.email;
    setState(() {
      _isEditing = true;
      _editingId = r.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des rédacteurs"),
        centerTitle: true,
        backgroundColor: Colors.purple, // 🎨 violet
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- FORMULAIRE ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomCtrl,
                              decoration: const InputDecoration(
                                labelText: "Nom",
                                hintText: "Ex: Dupont",
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "Nom requis"
                                  : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _prenomCtrl,
                              decoration: const InputDecoration(
                                labelText: "Prénom",
                                hintText: "Ex: Alice",
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "Prénom requis"
                                  : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintText: "exemple@domaine.com",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple, // 🎨 violet
                              ),
                              onPressed: _addOrUpdate,
                              icon: Icon(
                                _isEditing ? Icons.save : Icons.add,
                                color: Colors.white,
                              ),
                              label: Text(
                                _isEditing ? "Enregistrer" : "Ajouter",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _resetForm,
                                icon: const Icon(Icons.close),
                                label: const Text("Annuler"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Liste des rédacteurs",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // --- LISTE ---
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text("Aucun rédacteur pour le moment.")),
              )
            else
              ..._items.map(
                (r) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Text(
                        (r.nom.isNotEmpty ? r.nom[0] : '?').toUpperCase(),
                        style: const TextStyle(color: Colors.purple),
                      ),
                    ),
                    title: Text("${r.prenom} ${r.nom}"),
                    subtitle: Text(r.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: "Modifier",
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _startEdit(r),
                        ),
                        IconButton(
                          tooltip: "Supprimer",
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _delete(r.id!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
