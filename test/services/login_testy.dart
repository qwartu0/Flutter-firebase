import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:laba12/providers/auth_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_testy.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  Stream,
])
void main() {
  late AuthProvider authProvider;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockStream<User?> mockAuthStateStream;

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testErrorCode = 'user-not-found';
  const testErrorMessage = 'No user found with this email.';

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockAuthStateStream = MockStream<User?>();

    when(mockAuth.authStateChanges()).thenAnswer((_) => mockAuthStateStream);
    when(mockAuthStateStream.listen(any)).thenAnswer((invocation) {
      return Stream<User?>.empty().listen(invocation.positionalArguments[0]);
    });

    authProvider = AuthProvider(auth: mockAuth, googleSignIn: mockGoogleSignIn);
  });

  group('Email/Password Authentication', () {
    test('Successful sign in with email and password', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await authProvider.signInWithEmail(testEmail, testPassword);

      expect(result, mockUserCredential);
      verify(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('Failed sign in with email and password - user not found', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(FirebaseAuthException(code: testErrorCode));

      expect(
            () => authProvider.signInWithEmail(testEmail, testPassword),
        throwsA(testErrorMessage),
      );
    });
  });

  group('Google Sign In', () {
    test('Successful Google sign in', () async {
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication)
          .thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(mockGoogleSignInAuthentication.accessToken)
          .thenReturn('google-access-token');
      when(mockGoogleSignInAuthentication.idToken)
          .thenReturn('google-id-token');
      when(mockAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await authProvider.signInWithGoogle();

      expect(result, mockUserCredential);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAuth.signInWithCredential(any)).called(1);
    });

    test('Google sign in cancelled by user', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await authProvider.signInWithGoogle();

      expect(result, null);
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAuth.signInWithCredential(any));
    });
  });

  group('Password Reset', () {
    test('Successful password reset', () async {
      when(mockAuth.sendPasswordResetEmail(email: testEmail))
          .thenAnswer((_) async => null);

      await authProvider.resetPassword(testEmail);

      verify(mockAuth.sendPasswordResetEmail(email: testEmail)).called(1);
    });

    test('Failed password reset - invalid email', () async {
      when(mockAuth.sendPasswordResetEmail(email: testEmail))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      expect(
            () => authProvider.resetPassword(testEmail),
        throwsA('The email address is not valid.'),
      );
    });
  });
}