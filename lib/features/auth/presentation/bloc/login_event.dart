part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String username;
  final String password;
  final String? region;

  const LoginSubmitted({
    required this.username,
    required this.password,
    this.region,
  });

  @override
  List<Object> get props => [username, password, region ?? ''];
}

class CheckAuthStatus extends LoginEvent {}

class LogoutRequested extends LoginEvent {}
