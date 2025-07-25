// main_background.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MainBackground extends StatelessWidget {
  final Widget? header;

  final Widget body;

  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? floatingActionButton;

  const MainBackground({
    super.key,
    this.header,
    required this.body,
    this.appBar,
    this.drawer,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final purpleColor = AppColors.background;
    final waveColor = AppColors.formBackground;

    bool isSearchScreen = false;
    if (appBar is AppBar) {
      final appBarWidget = appBar as AppBar;
      if (appBarWidget.title is Text) {
        final titleWidget = appBarWidget.title as Text;
        if (titleWidget.data == 'Buscar Filme') {
          isSearchScreen = true;
        }
      }
    }
    final double topPadding = isSearchScreen
        ? 230.0 // Padding menor para a tela de busca
        : (header != null ? 460.0 : 200.0); // Sua lógica original
    return Scaffold(
      backgroundColor: purpleColor,
      appBar: appBar,
      drawer: drawer,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: body,
            ),

            ClipPath(
              clipper: WaveClipper(),
              child: Container(height: 220, color: waveColor),
            ),

            if (header != null) Positioned(left: 20, right: 20, child: header!),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.2, size.height - 30.0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(
      size.width - (size.width / 3.2),
      size.height - 65,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
