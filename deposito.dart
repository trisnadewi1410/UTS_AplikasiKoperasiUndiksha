import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'nasabah_provider.dart';

class DepositoPage extends StatefulWidget {
  const DepositoPage({super.key});

  @override
  State<DepositoPage> createState() => _DepositoPageState();
}

class _DepositoPageState extends State<DepositoPage> {
  final _jumlahController = TextEditingController();
  final _tokenController = TextEditingController();

  void _depositSaldo(BuildContext context) {
    final nasabahProvider = context.read<NasabahProvider>();
    final saldo = nasabahProvider.saldo;
    final jumlah = double.tryParse(
            _jumlahController.text.replaceAll(',', '').replaceAll('.', '')) ??
        0;
    final token = _tokenController.text.trim();

    if (jumlah <= 0 || token.isEmpty) {
      _showDialog('Jumlah deposito atau token tidak valid', isSuccess: false);
      return;
    }

    if (token != '123') {
      _showDialog('Token salah. Silakan coba lagi.', isSuccess: false);
      return;
    }

    if (jumlah > saldo) {
      _showDialog('Saldo Anda tidak cukup untuk melakukan deposito',
          isSuccess: false);
      return;
    }

    final formattedJumlah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    ).format(jumlah);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Deposito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin mendepositokan sejumlah:'),
            const SizedBox(height: 8),
            Text(
              formattedJumlah,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Saldo akan berkurang sebesar $formattedJumlah'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              nasabahProvider.updateSaldo(saldo - jumlah);
              nasabahProvider.tambahMutasi('Deposito', 'Keluar', jumlah);
              Navigator.pop(context); // tutup konfirmasi
              _showDialog('Deposito berhasil sejumlah $formattedJumlah',
                  isSuccess: true);
              _jumlahController.clear();
              _tokenController.clear();
            },
            child: const Text('Ya, Setor'),
          ),
        ],
      ),
    );
  }

  void _showDialog(String message, {required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green[50] : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 48,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? 'Berhasil!' : 'Gagal!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSuccess ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: isSuccess ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saldo = context.watch<NasabahProvider>().saldo;
    final formattedSaldo =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2)
            .format(saldo);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deposito',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Saldo Saat Ini: $formattedSaldo',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Deposito',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _depositSaldo(context),
                icon: const Icon(Icons.savings, color: Colors.white),
                label: const Text(
                  'DEPOSIT SEKARANG',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
