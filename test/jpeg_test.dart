import 'dart:io';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  var dir = Directory('test/res/jpg');
  var files = dir.listSync(recursive: true);

  group('JPEG', () {
    for (var f in files) {
      if (f is! File || !f.path.endsWith('.jpg')) {
        continue;
      }

      String name = f.path.split(RegExp(r'(/|\\)')).last;
      test('$name', () {
        List<int> bytes = (f as File).readAsBytesSync();
        expect(JpegDecoder().isValidFile(bytes), equals(true));

        Image image = JpegDecoder().decodeImage(bytes);
        if (image == null) {
          throw ImageException('Unable to decode JPEG Image: $name.');
        }

        List<int> outJpg = JpegEncoder().encodeImage(image);
        File('out/jpg/${name}')
          ..createSync(recursive: true)
          ..writeAsBytesSync(outJpg);

        // Make sure we can read what we just wrote.
        Image image2 = JpegDecoder().decodeImage(outJpg);
        if (image2 == null) {
          throw ImageException('Unable to re-decode JPEG Image: $name.');
        }

        expect(image.width, equals(image2.width));
        expect(image.height, equals(image2.height));
      });
    }

    for (int i = 1; i < 9; ++i) {
      test('exif/orientation_$i/landscape', () {
        Image image = JpegDecoder().decodeImage(
            File('test/res/jpg/landscape_$i.jpg').readAsBytesSync());
        expect(image.exif.hasOrientation, equals(true));
        expect(image.exif.orientation, equals(i));
        File('out/jpg/landscape_$i.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(PngEncoder().encodeImage(bakeOrientation(image)));
      });

      test('exif/orientation_$i/portrait', () {
        Image image = JpegDecoder().decodeImage(
            File('test/res/jpg/portrait_$i.jpg').readAsBytesSync());
        expect(image.exif.hasOrientation, equals(true));
        expect(image.exif.orientation, equals(i));
        File('out/jpg/portrait_$i.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(PngEncoder().encodeImage(bakeOrientation(image)));
      });
    }
  });
}
