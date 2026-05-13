import 'package:flutter_test/flutter_test.dart';
import 'package:magic_8_ball/models/oracle_persona.dart';

void main() {
  group('OraclePersona', () {
    test('spark has correct properties', () {
      expect(OraclePersona.spark.name, equals('Spark'));
      expect(OraclePersona.spark.lengthTarget, equals(6));
      expect(OraclePersona.spark.maxWords, equals(8));
    });

    test('luna has correct properties', () {
      expect(OraclePersona.luna.name, equals('Luna'));
      expect(OraclePersona.luna.lengthTarget, equals(8));
      expect(OraclePersona.luna.maxWords, equals(10));
    });

    test('oraclePro has correct properties', () {
      expect(OraclePersona.oraclePro.name, equals('Oracle Pro'));
      expect(OraclePersona.oraclePro.lengthTarget, equals(10));
      expect(OraclePersona.oraclePro.maxWords, equals(12));
    });

    test('all personas have non-empty style and description', () {
      for (final persona in OraclePersona.values) {
        expect(persona.style, isNotEmpty);
        expect(persona.description, isNotEmpty);
      }
    });

    test('maxWords is lengthTarget + 2', () {
      for (final persona in OraclePersona.values) {
        expect(persona.maxWords, equals(persona.lengthTarget + 2));
      }
    });

    test('three personas exist', () {
      expect(OraclePersona.values.length, equals(3));
    });
  });
}
