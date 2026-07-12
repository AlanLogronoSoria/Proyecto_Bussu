import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../../data/repositories/tickets_repository_impl.dart';
import '../../domain/usecases/get_tickets_usecase.dart';

final ticketsRepositoryProvider = Provider<TicketsRepository>((_) => TicketsRepositoryImpl());
final getTicketsUseCaseProvider = Provider<GetTicketsUseCase>((ref) => GetTicketsUseCase(ref.watch(ticketsRepositoryProvider)));

final ticketsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final useCase = ref.watch(getTicketsUseCaseProvider);
  final result = await useCase.execute('current');
  return result.fold((_) => [], (t) => t);
});
