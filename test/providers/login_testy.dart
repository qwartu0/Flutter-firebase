import 'package:laba12/providers/auth_provider.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      authProvider = AuthProvider(auth: mockFirebaseAuth, googleSignIn: mockGoogleSignIn);
    });

    test('Sign in with email - Successful', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => null);

      final result = await authProvider.signInWithEmail('test@example.com', 'password');

      expect(result, isNull);
    });

    test('Sign in with email - Error', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(FirebaseAuthException(code: 'error-code'));

      expect(() => authProvider.signInWithEmail('test@example.com', 'password'), throwsA(isA<String>()));
    });

    test('Sign in with Google - Successful', () async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(mockGoogleSignInAuthentication.accessToken).thenReturn('access-token');
      when(mockGoogleSignInAuthentication.idToken).thenReturn('id-token');
      when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => null);

      final result = await authProvider.signInWithGoogle();

      expect(result, isNull);
    });
  });
}