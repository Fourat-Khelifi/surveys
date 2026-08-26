@Tags(['live'])
library;

// Integration smoke test against the real Supabase project.
//
// Runs the exact code path the app uses, so a failure here prints the actual
// exception instead of the UI's "Couldn't load this survey".
//
//   flutter test test/survey_service_live_test.dart
//
// Needs assets/.env and network access, so it is tagged `live`. Exclude it
// in CI with:  flutter test --exclude-tags live

import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surveys/services/auth_service.dart';
import 'package:surveys/services/survey_service.dart';

const _email = 'test@mail.com';
const _password = '11111111';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SurveyService service;

  setUpAll(() async {
    // TestWidgetsFlutterBinding installs an HttpOverrides that answers every
    // request with 400 and never touches the network. This test is explicitly
    // an integration check against the live project, so put it back.
    HttpOverrides.global = null;

    // supabase_flutter persists the session through shared_preferences, which
    // has no plugin implementation under `flutter test`.
    SharedPreferences.setMockInitialValues({});

    await dotenv.load(fileName: 'assets/.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    );
    await Supabase.instance.client.auth.signInWithPassword(
      email: _email,
      password: _password,
    );
    service = SurveyService();
  });

  test('every survey loads with its questions', () async {
    final available = await service.fetchAvailableSurveys();
    // ignore: avoid_print
    print('available: ${available.length}');

    final failures = <String>[];

    for (final summary in available) {
      try {
        final full = await service.fetchSurveyWithQuestions(summary.id);
        final questions = full.questions ?? [];
        // ignore: avoid_print
        print('  OK   ${summary.title} — ${questions.length} questions');
        expect(questions, isNotEmpty, reason: summary.title);
      } catch (e) {
        // ignore: avoid_print
        print('  FAIL ${summary.title}\n         $e');
        failures.add('${summary.title}: $e');
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('the intro screen fetch works for every survey', () async {
    final available = await service.fetchAvailableSurveys();
    final failures = <String>[];

    for (final summary in available) {
      try {
        await service.fetchSurvey(summary.id);
      } catch (e) {
        // ignore: avoid_print
        print('  FAIL fetchSurvey ${summary.title}\n         $e');
        failures.add('${summary.title}: $e');
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
  test('profile carries a full name, and renaming persists', () async {
    final auth = AuthService();

    final profile = await auth.fetchProfile();
    expect(profile, isNotNull);
    // ignore: avoid_print
    print(
      'profile: "${profile!.fullName}"  <${profile.email}>  '
      'initials=${profile.initials}  first=${profile.firstName}',
    );
    expect(
      profile.fullName,
      isNotNull,
      reason: 'the signup trigger / backfill should always set a name',
    );

    final original = profile.fullName!;
    final renamed = await auth.updateFullName('Ada Lovelace');
    expect(renamed.fullName, 'Ada Lovelace');
    expect(renamed.initials, 'AL');

    final reread = await auth.fetchProfile();
    expect(reread!.fullName, 'Ada Lovelace', reason: 'rename must persist');

    // Put it back so the demo account is left as it was found.
    final restored = await auth.updateFullName(original);
    expect(restored.fullName, original);
    // ignore: avoid_print
    print('rename verified and restored to "$original"');
  });

  test('a blank name is rejected before it reaches the database', () async {
    final auth = AuthService();
    await expectLater(auth.updateFullName('   '), throwsA(isA<AuthFailure>()));
  });
}
