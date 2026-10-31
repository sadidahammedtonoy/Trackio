import 'package:web/web.dart' as web;

const Map<String, String> _imageTopColors = {
  'assets/12bdb075678dee4c0ab2c5d092552294.jpg': '#E9E6DE',
  'assets/49d6567948370c7451a6d4c15ac8c376.jpg': '#F2F0EA',
  'assets/5cccc0b0228dc895465d0b1440a42ddb.jpg': '#F5E8DD',
  'assets/cbfb01f0c5de123998fc236ae6e55751.jpg': '#E4E5E6',
  'assets/e62b8bdea5ae49802f3ac19a109a6410.jpg': '#EBEAD4',
  'assets/newBackground.jpeg': '#D4C5B5',
  'assets/Cream and Beige Illustrative Background Portrait Document A4.png': '#FCFCFA',
  'assets/background.jpeg': '#CFC8C0',
  'assets/White Golden Floral Frame Background Facebook Story.jpg': '#FEFEFC',
  'assets/Pink Yellow Aesthetic Watercolor Background Document A4.jpg': '#FCF2F1',
  'assets/Mint Green Minimalist Watercolor Leaves Background Instagram Story.jpg': '#C9DCD7',
  'assets/Green and Purple Watercolor Background Document A4.jpg': '#D9DBF5',
  'assets/Brown Floral Watercolor Minimalist Notes Background A4 Document.jpg': '#FEFEFE',
  'assets/Blue Watercolor Background Document.jpg': '#EFF3FB',
  'assets/Blue and White Simple Watercolor Background Instagram Story.jpg': '#F5EFF1',
  'assets/Blue Cute Simple Background Instagram Story.jpg': '#CCDFF7',
  'assets/Green Aesthetic Poster Portrait.jpg': '#E6F0E3',
  'assets/Green Modern Welcome Spring (Instagram Story).jpg': '#EDF1F8',
};

void updateWebBackgroundSync({bool? isColor, String? source}) {
  try {
    final htmlEl = web.document.documentElement as web.HTMLElement?;
    final bodyEl = web.document.body;

    if (isColor == true && source != null) {
      final color = source.startsWith('#') ? source : '#$source';
      htmlEl?.style.backgroundColor = color;
      bodyEl?.style.backgroundColor = color;
      bodyEl?.style.backgroundImage = 'none';
      _updateThemeColor(color);
    } else if (source != null && source.isNotEmpty) {
      final topColor = _imageTopColors[source] ?? '#C9DCD7';
      _updateThemeColor(topColor);

      final encoded = Uri.encodeFull(source);
      final url = 'assets/$encoded';

      htmlEl?.style.backgroundColor = topColor;
      bodyEl?.style.backgroundColor = topColor;
      bodyEl?.style.backgroundImage = "url('$url')";
      bodyEl?.style.backgroundSize = "cover";
      bodyEl?.style.backgroundPosition = "center";
      bodyEl?.style.backgroundRepeat = "no-repeat";
    }
  } catch (e) {
    // Platform fallback safe
  }
}

void _updateThemeColor(String color) {
  try {
    var meta = web.document.querySelector('meta[name="theme-color"]');
    if (meta == null) {
      final newMeta = web.document.createElement('meta');
      newMeta.setAttribute('name', 'theme-color');
      newMeta.setAttribute('content', color);
      web.document.head?.appendChild(newMeta);
    } else {
      meta.setAttribute('content', color);
    }
  } catch (_) {}
}
