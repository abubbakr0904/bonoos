import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/home/domain/entity/topic.dart';
import 'package:bonoos/features/home/domain/entity/topic_question.dart';
import 'package:dartz/dartz.dart';

abstract class TopicsRepository {
  Future<Either<Failure, List<Topic>>> fetchTopics();

  Future<Either<Failure, List<TopicQuestion>>> fetchTopicQuestions(int topicId);
}
