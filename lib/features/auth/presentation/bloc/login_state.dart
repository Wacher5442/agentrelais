part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;
  final String activeRegion;
  final String campagne;
  final List<CommodityEntity> commodities;

  const LoginSuccess({
    required this.user,
    required this.activeRegion,
    required this.campagne,
    this.commodities = const [],
  });

  @override
  List<Object> get props => [user, activeRegion, campagne, commodities];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});

  @override
  List<Object> get props => [message];
}
