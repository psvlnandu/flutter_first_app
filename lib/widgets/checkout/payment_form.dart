import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PaymentForm extends StatefulWidget {
  const PaymentForm({super.key});
  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  String cardNumber = '', expiryDate = '', cardHolderName = '', cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreditCardWidget(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          showBackView: isCvvFocused, // Flips card automatically!
          onCreditCardWidgetChange: (brand) {}, // Detects Visa/Amex
          bankName: 'Old Market Bank',
          cardBgColor: Colors.brown[700]!,
        ),
        CreditCardForm(
          formKey: formKey,
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardHolderName: cardHolderName,
          cvvCode: cvvCode,
          onCreditCardModelChange: (model) {
            setState(() {
              cardNumber = model.cardNumber;
              expiryDate = model.expiryDate;
              cardHolderName = model.cardHolderName;
              cvvCode = model.cvvCode;
              isCvvFocused = model.isCvvFocused;
            });
          },
        ),
      ],
    );
  }
}
