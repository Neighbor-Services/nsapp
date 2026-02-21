import 'package:flutter/material.dart';

const Color appOrangeColor1 = Color(0xFFFCA34D);
const Color appOrangeColor2 = Color(0xFFFBB359);
const Color appLightPurpleColor1 = Color(0xFFD6CDFE);
const Color appDeepBlueColor1 = Color(0xFF1564C0);
const Color appDeepBlueColor2 = Color(0xFF0D47A1); // Deep blue for backgrounds
const Color appSuffixIconColor = Color(0xFF60778C);
const Color appShadowColor = Color(0xFF99ABC6);
const Color appSmallTextColor = Color(0xFF524B6B);
const Color appBackgroundColor = Color(0xFFF9F9F9);
const Color appBlueCardColor = Color(0xFF130160);
const Color appLightBlueCard = Color(0xFFAFECFE);
const Color appMiddleBlueCard = Color(0xFFBEAFFE);
const Color appCardFooterColor = Color(0xFFC4C4C4);
const Color appFilterAppBarColor = Color(0xFF0D0140);
const Color appFilterBtnColor = Color(0xFFCBC9D4);
const Color appWhiteColor = Color(0xFFFFFFFF);
const Color appBlackColor = Color(0xFF000000);
const Color appGreyColor = Color(0xFF999999);
const Color appLightTextColor = Color(0xFF60778C);
const Color appDarkTextColor = Color(0xFF333333);

// Glassmorphism Colors
const Color glassWhite = Color(0x1AFFFFFF);
const Color glassWhiteLight = Color(0x33FFFFFF);
const Color glassBorder = Color(0x40FFFFFF);
const Color glassBorderLight = Color(0x20FFFFFF);
const Color gradientStart = Color(0xFF667eea);
const Color gradientEnd = Color(0xFF764ba2);
const Color gradientStartAlt = Color.fromARGB(255, 20, 22, 66);
const Color gradientEndAlt = Color.fromARGB(255, 4, 7, 51);
const Color glowColor = Color.fromARGB(255, 25, 6, 77);
const Color glowColorLight = Color(0x407C4DFF);

// Dark mode glass colors
const Color glassDark = Color(0x1A000000);
const Color glassBorderDark = Color(0x30FFFFFF);

const String mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8ec3b9"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1a3646"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#64779e"
      }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4b6878"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#334e87"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6f9ba5"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#3C7680"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#304a7d"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2c6675"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#255763"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#b0d5ce"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#023e58"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#98a5be"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1d2c4d"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#283d6a"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3a4762"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#0e1626"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4e6d70"
      }
    ]
  }
]
''';
