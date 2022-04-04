import 'package:flutter/material.dart';
import 'dart:math';
import '../model/job.dart';

class DeleteDialog extends StatefulWidget {
  final Job? job;
  final Function() onClickedDelete;

  const DeleteDialog({
    Key? key,
    this.job,
    required this.onClickedDelete,
  }) : super(key: key);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

const title = "Supprimer";

class _DeleteDialogState extends State<DeleteDialog> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text("êtes-vous sûr de vouloir supprimer"),
      actions: [
        buildCancelButton(context),
        buildDeleteButton(context),
      ],
    );
  }

  Widget buildCancelButton(BuildContext context) => TextButton(
    child: Text('Annuler'),
    onPressed: () => Navigator.of(context).pop(),
  );

  Widget buildDeleteButton(BuildContext context) {
    return TextButton(
        child: Text("Supprimer"),
        onPressed: () async {
          widget.onClickedDelete();
          Navigator.of(context).pop();
        }
    );
  }

}