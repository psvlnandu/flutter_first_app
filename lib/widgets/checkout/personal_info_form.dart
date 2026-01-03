import 'package:flutter/material.dart';

/*
To keep it simple but powerful, 
each widget(in checkout folder) will take the TextEditingControllers as parameters. 
This way, the Parent (CheckoutScreen) still owns the data, but the Child (the Form) handles the look.
*/
class PersonalInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const PersonalInfoForm({super.key, required this.nameController, required this.emailController, required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person)),
          validator: (v) => v!.isEmpty ? 'Name required' : null,
        ),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
          validator: (value) => value!.isEmpty ? 'Email required' : null,
        ),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
          validator: (value) => value!.isEmpty ? 'Phone required' : null,
        ),
      ],
    );
  }
}