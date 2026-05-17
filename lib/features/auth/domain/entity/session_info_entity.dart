import 'package:equatable/equatable.dart';

class SessionInfoEntity extends Equatable {
  final bool hasSession;
  final bool canUseBiometric;

  const SessionInfoEntity({
    required this.hasSession,
    required this.canUseBiometric,
  });

  @override
  List<Object?> get props => [hasSession, canUseBiometric];
}
