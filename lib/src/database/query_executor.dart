import 'package:database_repository/database_repository.dart';
import 'package:supabase/supabase.dart';

/// mixin that provides the actual implementation for executing the query using
/// supabase
mixin QueryExecutor implements DatabaseAdapter {
  /// Tries to store queries payload in supabase
  Future<QueryResult> create(Query query, SupabaseClient client) async {
    final response =
        await client.from(query.entityName).insert(query.payload).execute();

    return _queryResultFromPostgrestResponse(query, response);
  }

  /// Tries to store queries payload in supabase
  Future<QueryResult> update(Query query, SupabaseClient client) async {
    final response =
        await client.from(query.entityName).upsert(query.payload).execute();

    return _queryResultFromPostgrestResponse(query, response);
  }

  /// Tries to delete payload from supabase
  Future<QueryResult> delete(Query query, SupabaseClient client) async {
    final response = await client
        .from(query.entityName)
        .delete()
        .eq('id', query.payload['id'])
        .execute();

    return _queryResultFromPostgrestResponse(query, response);
  }

  /// Tries to fetch payload from supabase
  Future<QueryResult> read(Query query, SupabaseClient client) async {
    var filterBuilder = await client.from(query.entityName).select();
    if (query.payload.containsKey('id')) {
      final responseForId =
          await filterBuilder.eq('id', query.payload['id']).execute();
      return _queryResultFromPostgrestResponse(query, responseForId);
    }

    if (query.where.isNotEmpty) {
      for (final constraint in query.where) {
        filterBuilder = _applyConstraint(constraint, filterBuilder);
      }
    }

    PostgrestTransformBuilder? transformBuilder;
    if (query.limit != null && query.limit! > 0) {
      transformBuilder =
          (transformBuilder ?? filterBuilder).limit(query.limit!);
    }

    final response = await (transformBuilder ?? filterBuilder).execute();
    return _queryResultFromPostgrestResponse(query, response);
  }

  QueryResult _queryResultFromPostgrestResponse(
    Query query,
    PostgrestResponse response,
  ) {
    if (response.hasError) {
      return QueryResult.failed(
        query,
        errorMsg: response.error?.message ??
            'Error with PostgREST without Error Message',
      );
    }

    if (response.data != null) {
      return QueryResult.success(query, payload: response.data);
    }

    return QueryResult.failed(
      query,
      errorMsg: 'Unknown Error with PostgREST',
    );
  }

  PostgrestFilterBuilder _applyConstraint(
    Constraint constraint,
    PostgrestFilterBuilder builder,
  ) {
    if (constraint is Equals) {
      return builder.eq(constraint.key, constraint.value);
    }

    if (constraint is NotEquals) {
      return builder.neq(constraint.key, constraint.value);
    }

    if (constraint is GreaterThan) {
      return builder.gt(constraint.key, constraint.value);
    }

    if (constraint is GreaterThanOrEquals) {
      return builder.gte(constraint.key, constraint.value);
    }

    if (constraint is LessThan) {
      return builder.lt(constraint.key, constraint.value);
    }

    if (constraint is LessThanOrEquals) {
      return builder.lte(constraint.key, constraint.value);
    }

    if (constraint is IsNull) {
      return builder.is_(constraint.key, null);
    }

    if (constraint is IsNotNull) {
      return builder.neq(constraint.key, null);
    }

    if (constraint is IsUnset) {
      // For postgREST any unset value will be null if the field is nullable.
      // If field is not nullable it cannot be inserted without an explicit
      // value therefor if it is not null it is definitely set
      return builder.is_(constraint.key, null);
    }

    if (constraint is IsSet) {
      // This check is a no-op for postgREST as we cannot differantiate between 
      // null and unset
      return builder;
    }

    if (constraint is IsFalse) {
      return builder.is_(constraint.key, false);
    }

    if (constraint is IsTrue) {
      return builder.is_(constraint.key, true);
    }

    if (constraint is IsFalsey) {
      throw ConstraintUnsupportedException(
          constraint: constraint, adapter: this);
    }

    if (constraint is IsTruthy) {
      throw ConstraintUnsupportedException(
          constraint: constraint, adapter: this);
    }

    if (constraint is Contains) {
      return builder.contains(constraint.key, constraint.value);
    }

    if (constraint is ContainsNot) {
      return builder.not(constraint.key, 'cs', constraint.value);
    }

    if (constraint is InList) {
      return builder.in_(constraint.key, constraint.value as List<dynamic>);
    }

    if (constraint is NotInList) {
      return builder.not(
        constraint.key,
        'in',
        constraint.value as List<dynamic>,
      );
    }

    return builder;
  }
}
