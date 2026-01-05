import 'package:flutter/material.dart';
/*
- With card detection- amex, visa, master
*/
class BillingInfoForm extends StatelessWidget {
  final TextEditingController cardController;
  final Function(String) onCardChanged;

  const BillingInfoForm({super.key, required this.cardController, required this.onCardChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: cardController,
          onChanged: onCardChanged,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            // prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          // validator: (value) => value!.length != 16 ? 'Invalid Card Number' : null,
        ),


        TextFormField(
          controller: cardController,
          onChanged: onCardChanged,
          decoration: const InputDecoration(
            labelText: 'CVV',
          ),
          keyboardType: TextInputType.number,
          // validator: (value) => value!.length != 3 ? 'Invalid CVV' : null,
        ),


        TextFormField(
          controller: cardController,
          onChanged: onCardChanged,
          decoration: const InputDecoration(
            labelText: 'MM/YY ',
          ),
          keyboardType: TextInputType.text,
          // validator: (value) => value!.length != 4 ? 'Invalid Expiry' : null,
        ),
        // Add CVV and Expiry here...
      ],
    );
  }
}