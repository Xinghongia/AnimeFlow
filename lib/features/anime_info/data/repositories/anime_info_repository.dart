import 'package:anime_flow/features/anime_info/data/datasources/anime_info_local_data_source.dart';
import 'package:anime_flow/features/anime_info/data/datasources/anime_info_remote_data_source.dart';
import 'package:anime_flow/shared/models/bangumi/actor_item.dart';
import 'package:anime_flow/shared/models/bangumi/producers_item.dart';
import 'package:anime_flow/shared/models/bangumi/related_subjects_item.dart';
import 'package:anime_flow/shared/models/bangumi/subject_comments_item.dart';
import 'package:anime_flow/shared/models/bangumi/subjects_info_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AnimeInfoRepository {
  static const _cacheMaxAge = Duration(hours: 12);

  final _local = AnimeInfoLocalDataSource();
  final _remote = AnimeInfoRemoteDataSource();
  Future<void> _cacheReady = Future.value();
  int _generation = 0;
  bool _cacheReadable = true;

  /// 在下次读取前清空缓存，并阻止失效前发出的请求重新写入旧数据。
  void invalidateCache() {
    final generation = ++_generation;
    _cacheReadable = false;
    _cacheReady = _cacheReady.then((_) => _local.clear()).then((_) {
      if (generation == _generation) _cacheReadable = true;
    }).catchError(
      (Object error) => debugPrint('Failed to clear subject cache: $error'),
    );
  }

  /// 先返回缓存的条目详情，缓存过期时再异步请求并推送最新数据。
  Stream<SubjectsInfoItem> watchSubject(
    int subjectId, {
    required String? sessionId,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async* {
    var hasCachedSubject = false;
    // 缓存失效不代表订阅已取消。仍在等待详情的页面需要重新加载，
    // 否则空流结束会使 StreamNotifier 一直停留在 AsyncLoading。
    while (true) {
      await _cacheReady;
      if (cancelToken?.isCancelled ?? false) throw cancelToken!.cancelError!;
      final generation = _generation;
      if (!forceRefresh && _cacheReadable) {
        try {
          final cached = _local.read(subjectId, sessionId: sessionId);
          if (cached != null) {
            hasCachedSubject = true;
            yield cached.subject;
            if (cancelToken?.isCancelled ?? false) return;
            if (generation != _generation) continue;
            final age = DateTime.now().millisecondsSinceEpoch - cached.cachedAt;
            if (age >= 0 && age < _cacheMaxAge.inMilliseconds) return;
          }
        } catch (error) {
          debugPrint('Failed to read subject cache: $error');
        }
      }
      if (cancelToken?.isCancelled ?? false) return;
      if (generation != _generation) continue;
      try {
        final subject =
            await _remote.getSubject(subjectId, cancelToken: cancelToken);
        if (cancelToken?.isCancelled ?? false) return;
        if (generation != _generation) continue;
        await cacheSubject(subject, sessionId: sessionId);
        if (cancelToken?.isCancelled ?? false) return;
        if (generation != _generation) continue;
        yield subject;
        return;
      } catch (error) {
        if (cancelToken?.isCancelled ?? false) return;
        if (generation != _generation) continue;
        if (!hasCachedSubject) rethrow;
        debugPrint('Failed to refresh subject cache: $error');
        return;
      }
    }
  }

  /// 缓存写入失败不影响已成功的请求或本地修改。
  Future<void> cacheSubject(
    SubjectsInfoItem subject, {
    required String? sessionId,
  }) async {
    final generation = _generation;
    await _cacheReady;
    if (generation != _generation) return;
    try {
      await _local.write(subject, sessionId: sessionId);
    } catch (error) {
      debugPrint('Failed to write subject cache: $error');
    }
  }

  Future<List<String>> getStills(int subjectId, {CancelToken? cancelToken}) =>
      _remote.getStills(subjectId, cancelToken: cancelToken);

  Future<SubjectCommentItem> getComments(
    int subjectId, {
    required int limit,
    required int offset,
    CancelToken? cancelToken,
  }) =>
      _remote.getComments(subjectId,
          limit: limit, offset: offset, cancelToken: cancelToken);

  Future<SubjectRelationItem> getRelated(
    int subjectId, {
    required int limit,
    required int offset,
    CancelToken? cancelToken,
  }) =>
      _remote.getRelated(subjectId,
          limit: limit, offset: offset, cancelToken: cancelToken);

  Future<CharactersItem> getCharacters(
    int subjectId, {
    required int limit,
    required int offset,
    CancelToken? cancelToken,
  }) =>
      _remote.getCharacters(subjectId,
          limit: limit, offset: offset, cancelToken: cancelToken);

  Future<ProducersItem> getProducers(
    int subjectId, {
    required int limit,
    required int offset,
    CancelToken? cancelToken,
  }) =>
      _remote.getProducers(subjectId,
          limit: limit, offset: offset, cancelToken: cancelToken);
}
