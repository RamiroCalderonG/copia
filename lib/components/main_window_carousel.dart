import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MainCarousel extends StatefulWidget {
  const MainCarousel({super.key});

  @override
  State<MainCarousel> createState() => _MainCarouselState();
}

class _MainCarouselState extends State<MainCarousel> {
  final List<String> assetImg = [
    'assets/images/aulaVirtual.png',
    'assets/images/calendario.png',
    'assets/images/instalaciones.png',
    'assets/images/hsLogo.png'
  ];

  final List<String> links = [
    'https://oxschool.edu.mx/index.aspx',
    'https://oxschool.edu.mx/index.aspx?seccion=calendario',
    'https://oxschool.edu.mx/index.aspx?seccion=instalaciones',
    'https://oxschool.edu.mx/index.aspx?seccion=aulavirtualacceso',
    'https://hs.oxschool.edu.mx/'
  ];

  final themeMode = ValueNotifier(2);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
        options: CarouselOptions(
          height: 150,
          viewportFraction: 1 / 5,
          autoPlay: true,
          enlargeCenterPage: true,
        ),
        itemCount: assetImg.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          return GestureDetector(
            onTap: () {
              Uri _url = Uri.parse(links[index]);
              _launchUrl(_url);
            },
            child: Card(
              elevation: 6,
              shadowColor: Color.fromARGB(121, 219, 217, 217),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.5),
                    //     spreadRadius: 1,
                    //     blurRadius: 1.2,
                    //     offset: Offset(0, 3), // changes position of shadow
                    //   ),
                    // ],
                    ),
                padding: EdgeInsets.all(3),
                child: Image.asset(
                  assetImg[index],
                  fit: BoxFit.cover,
                  width: 300,
                ),
              ),
            ),
          );
        });
  }

  Future<void> _launchUrl(_url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
