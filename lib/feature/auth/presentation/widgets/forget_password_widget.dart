import 'package:flutter/material.dart';

import '../../../../core/utils/widgets/custom_button.dart';

class ForgetPasswordWidget extends StatelessWidget {
  const ForgetPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomButton(
        label: 'نسيت كلمة المرور؟',
        onPressed: () {},
        variant: ButtonVariant.text,
        width: 200,
        fontSize: 14,
        height: 35,
      ),
    );
  }
}
