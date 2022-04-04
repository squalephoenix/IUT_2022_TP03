import 'package:flutter/material.dart';
import 'dart:math';
import '../model/job.dart';

class JobDialog extends StatefulWidget {
  final Job? job;
  final Function(String name, double brut, double net, String statut, String comment) onClickedDone;

  const JobDialog({
    Key? key,
    this.job,
    required this.onClickedDone,
  }) : super(key: key);

  @override
  _JobDialogState createState() => _JobDialogState();
}

class _JobDialogState extends State<JobDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final brutController = TextEditingController();
  final netController = TextEditingController();
  final commentController = TextEditingController();

  final items = ['Salarié non-cadre 22%', 'Salarié cadre 25%', 'Fonction publique 15%', 'Profession libérale 45%', 'Portage salarial 51%'];
  final pourcentages = [0.78, 0.75, 0.85, 0.55, 0.49];

  String? dropdownValue = 'Salarié non-cadre 22%';
  int dropdownIndex = 0;

  double roundDouble(double value, int places){
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  double calculSalaire(double salaire, bool isBrut, double pourcentage){

    if(!isBrut) {
      pourcentage += 1;
    }

    return roundDouble(salaire * pourcentage, 2);

  }

  onBrutChange(){
    setState(() {
      double? brut = double.tryParse(brutController.text);
      double net = 0;
      if(brut != null){
        net = calculSalaire(brut, true, pourcentages[dropdownIndex]);
      }

      if(net >= 0) {
        netController.text = net.toString();
      }
    });
  }

  onNetChange(){
    setState(() {
      double? net = double.tryParse(netController.text);
      double brut = 0;
      if(net != null){
        brut = calculSalaire(net, false, pourcentages[dropdownIndex]);
      }
      if(brut >= 0) {
        brutController.text = brut.toString();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.job != null) {
      final job = widget.job!;

      nameController.text = job.name;
      brutController.text = job.brut.toString();
      netController.text = job.net.toString();
      commentController.text = job.comment;

      dropdownValue = job.statut;
      dropdownIndex = items.indexOf(dropdownValue!);

    }
  }

  @override
  void dispose() {

    nameController.dispose();
    brutController.dispose();
    netController.dispose();
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.job != null;
    final title = isEditing ? 'Editer une offre' : 'Ajouter une offre';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              buildName(),
              const SizedBox(height: 8),
              buildBrut(),
              const SizedBox(height: 8),
              buildNet(),
              const SizedBox(height: 8),
              buildStatut(),
              const SizedBox(height: 8),
              buildComment(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  Widget buildName() => TextFormField(
        controller: nameController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          icon: Icon(Icons.business),
          labelText: 'Nom de l\'entreprise',
        ),
        maxLines: 2,
        validator: (name) =>
            name != null && name.isEmpty ? 'Saisir un nom' : null,
      );

  Widget buildBrut() => TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
            icon: Icon(Icons.euro),
            labelText: 'Mensuel Brut',
            suffixText: "EUR"
        ),
        keyboardType: TextInputType.number,
        validator: (amount) => amount != null && double.tryParse(amount) == null
            ? 'Saisir un nombre valide'
            : null,
        onChanged: (text){
          onBrutChange();
        },
        controller: brutController,
      );

  Widget buildNet() => TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          icon: Icon(Icons.euro),
          labelText: 'Mensuel Net',
          suffixText: "EUR"
        ),
        keyboardType: TextInputType.number,
        validator: (amount) => amount != null && double.tryParse(amount) == null
            ? 'Saisir un nombre valide'
            : null,
        onChanged: (text){
          onNetChange();
        },
        controller: netController,

      );





  DropdownMenuItem<String> builMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );

  Widget buildStatut() => DropdownButtonFormField<String>(
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      icon: Icon(Icons.account_circle),
      labelText: 'Statut',
    ),
    value: dropdownValue,
    items: items.map(builMenuItem).toList(),
    onChanged: (value) => setState(() {
      if(value != null){
        dropdownValue = value;
        dropdownIndex = items.indexOf(value);
      }
      onBrutChange();
    }),
    validator: (name) => name != null && name.isEmpty ? 'Statut' : null,
  );

  Widget buildComment() => TextFormField(
    controller: commentController,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      icon: Icon(Icons.rate_review),
      labelText: 'Commentaire',
    ),
    maxLines: 5,
    keyboardType: TextInputType.multiline,
    validator: (name) =>
    name != null && name.isEmpty ? 'Saisir un commentaire' : null,
  );

  Widget buildCancelButton(BuildContext context) => TextButton(
        child: Text('Annuler'),
        onPressed: () => Navigator.of(context).pop(),
      );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Enregistrer' : 'Ajouter';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text.substring(0, 1).toUpperCase() + nameController.text.substring(1, nameController.text.length);
          final brut = double.tryParse(brutController.text) ?? 0;
          final net = double.tryParse(netController.text) ?? 0;
          final statut = dropdownValue!;
          final comment = commentController.text;


          widget.onClickedDone(name, brut, net, statut, comment);

          Navigator.of(context).pop();
        }
      },
    );
  }
}
