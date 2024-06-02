import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmo/l10n/l10n.dart';
import 'package:socialmo/lang/app_local.dart';
import 'package:socialmo/lang/setting_provider.dart';
import 'package:socialmo/lang/shared_pref.dart';

class AnotherPage extends StatefulWidget {
  @override
  _AnotherPageState createState() => _AnotherPageState();
}

class _AnotherPageState extends State<AnotherPage> {
  @override
  Widget build(BuildContext context) {
    AppLocal.init(context);
    SettingProvider prov = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.language),
            onSelected: (String? value) {
              if (value != null) {
                setState(() {
                  SharedPref.addLang(value);
                  prov.updateLocal(value);
                  print(SharedPref.lang);
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return List.generate(
                L10n.all.length,
                (index) => PopupMenuItem<String>(
                  value: L10n.all[index].languageCode,
                  child: Text(
                    L10n.all[index].languageCode == 'en'
                        ? AppLocal.loc.langEN
                        : AppLocal.loc.langAR,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
