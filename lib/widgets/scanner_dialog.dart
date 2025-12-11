import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Dialog simples de scanner. Retorna o código lido via Navigator.pop(code).
class ScannerDialog extends StatefulWidget {
  const ScannerDialog({super.key});

  @override
  State<ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<ScannerDialog> {
  late final MobileScannerController _controller;
  bool _handled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.all],
      onPermissionSet: (granted) {
        if (!granted) {
          setState(() {
            _errorMessage =
                'Permissão de câmera negada. Libere o acesso nas configurações do navegador e recarregue.';
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code.isNotEmpty) {
      _handled = true;
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return _CenteredMessage(
                    text:
                        'Não foi possível acessar a câmera.\nVerifique permissões e se há câmera disponível.\nDetalhe: ${error.errorDetails?.message ?? error.toString()}');
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white70, width: 2),
                  ),
                ),
                child: SizedBox(width: 200, height: 200),
              ),
            ),
            if (_errorMessage != null)
              _CenteredMessage(
                  text:
                      'Não foi possível usar a câmera.\n$_errorMessage\nSe já negou antes, limpe as permissões do site e recarregue.'),
          ],
        ),
      ),
    );
  }
}

/// Helper para abrir o dialog e retornar o código lido.
Future<String?> showScannerDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const ScannerDialog(),
  );
}

class _CenteredMessage extends StatelessWidget {
  final String text;
  const _CenteredMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
