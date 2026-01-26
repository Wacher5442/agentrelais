part of 'change_password_bloc.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String userId;
  final String newPassword;

  const ChangePasswordSubmitted({
    required this.userId,
    required this.newPassword,
  });

  @override
  List<Object> get props => [userId, newPassword];
}
