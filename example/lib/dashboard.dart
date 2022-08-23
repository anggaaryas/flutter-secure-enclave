import 'package:flutter/material.dart';
import 'package:secure_enclave_example/app_password.dart';
import 'package:secure_enclave_example/app_password_biomery.dart';
import 'package:secure_enclave_example/biometry_passcode.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppPassword(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: Text('App password'),
                    ),
                  ),
                ),
              ),
            ),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BiometryPasscode(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: Text('Biometry / Passcode'),
                    ),
                  ),
                ),
              ),
            ),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppPasswordBiometry(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 100,
                    child: Center(
                      child: Text('App password / Biometry'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}