import 'package:fpdart/fpdart.dart';

import '../../failures/failure.dart';
import '../entities/message.dart';
import '../repositories/coaching_repository.dart';

class GetCoachingResponse {
  GetCoachingResponse(this.repository);

  final CoachingRepository repository;

  Future<Either<Failure, Message>> call(String userMessage) async {
    return repository.sendMessage(userMessage);
  }
}
