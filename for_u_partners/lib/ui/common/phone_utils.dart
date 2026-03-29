import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

/// Effectue un appel téléphonique
Future<void> makePhoneCall(String number) async {
  final Uri callUri = Uri(scheme: 'tel', path: number);
  print("Number: $number");
  
  if (Platform.isAndroid) {
    // Vérifier/demander la permission CALL_PHONE
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        throw 'Permission d\'appel refusée';
      }
    }

    // Lancer directement l'appel
    if (await canLaunchUrl(callUri)) {
      await launchUrl(
        callUri,
        mode: LaunchMode.externalApplication, // ouvre direct
      );
    }
  } else if (Platform.isIOS) {
    // Sur iOS → obligé d'ouvrir l'app Téléphone
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  } else {
    throw 'Plateforme non supportée';
  }
}

/// Ouvre WhatsApp avec un numéro
Future<void> makeWhatsAppCall(String number) async {
  // Format WhatsApp → sans espaces, avec indicatif international
  // Nettoyer le numéro (enlever espaces, tirets, etc.)
  final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
  
  final Uri url = Uri.parse("whatsapp://send?phone=$cleanNumber");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    // fallback vers la version web
    final Uri webUrl = Uri.parse("https://wa.me/$cleanNumber");
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir WhatsApp';
    }
  }
}
