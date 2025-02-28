import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

toastMessage({
  required BuildContext context,
  required String message,
  DelightSnackbarPosition? position,
  Icon? leadingIcon,
  Color? messageColor,
  Color? toastColor,
  Color? borderColor,
}) {
  late DelightToastBar? toastBar;
  toastBar = DelightToastBar(
    position: position ?? DelightSnackbarPosition.bottom,
    autoDismiss: true,
    builder: (context) => SizedBox(
      child: Container(
        decoration: BoxDecoration(
          color: toastColor ?? Colors.blue[200],
          border: Border.all(
            color: borderColor ?? Colors.grey[600]!,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: ToastCard(
          trailing: IconButton(
            onPressed: () => toastBar?.remove(),
            icon: const Icon(Icons.cancel_outlined),
          ),
          leading: leadingIcon ??
              const Icon(
                Icons.flutter_dash,
                size: 28,
              ),
          title: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: messageColor ?? Colors.black,
            ),
          ),
          color: Colors.transparent,
        ),
      ),
    ),
  );
  toastBar.show(context);
}
