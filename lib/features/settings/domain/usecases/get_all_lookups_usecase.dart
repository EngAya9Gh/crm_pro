import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/lookup_entities.dart';
import '../../domain/entities/product.dart';

class AllLookups extends Equatable {
  final List<StatusEntity> clientStatuses; // Renamed from statuses for clarity
  final List<TagEntity> clientTags; // Renamed from tags
  final List<RegionEntity> regions;
  final List<SourceEntity> sources;
  final List<BehaviorEntity> behaviors;
  final List<InvalidReasonEntity> invalidReasons;
  final List<TeamEntity> teams;
  final List<RoleEntity> roles;
  final List<PermissionEntity> permissions;
  final List<InvoiceTagEntity> invoiceTags;
  final List<Product> products;
  final List<CommentTypeEntity> commentTypes;
  final List<CityEntity> cities; // Add cities here for convenience

  const AllLookups({
    this.clientStatuses = const [],
    this.clientTags = const [],
    this.regions = const [],
    this.sources = const [],
    this.behaviors = const [],
    this.invalidReasons = const [],
    this.teams = const [],
    this.roles = const [],
    this.permissions = const [],
    this.invoiceTags = const [],
    this.products = const [],
    this.commentTypes = const [],
    this.cities = const [],
  });

  @override
  List<Object?> get props => [
    clientStatuses,
    clientTags,
    regions,
    sources,
    behaviors,
    invalidReasons,
    teams,
    roles,
    permissions,
    invoiceTags,
    products,
    commentTypes,
    cities,
  ];
}

class GetAllLookupsUseCase {
  final SettingsRepository repository;

  GetAllLookupsUseCase(this.repository);

  Future<Either<Failure, AllLookups>> call() async {
    final results = await Future.wait([
      repository.getClientStatuses(),
      repository.getClientTags(),
      repository.getRegions(),
      repository.getSources(),
      repository.getBehaviors(),
      repository.getInvalidReasons(),
      repository.getTeams(),
      repository.getRoles(),
      repository.getPermissions(),
      repository.getInvoiceTags(),
      repository.getProducts(),
      repository.getCommentTypes(),
      repository.getCities(), // Fetch all cities
    ]);

    final statusesResult = results[0] as Either<Failure, List<StatusEntity>>;
    final tagsResult = results[1] as Either<Failure, List<TagEntity>>;
    final regionsResult = results[2] as Either<Failure, List<RegionEntity>>;
    final sourcesResult = results[3] as Either<Failure, List<SourceEntity>>;
    final behaviorsResult = results[4] as Either<Failure, List<BehaviorEntity>>;
    final invalidReasonsResult =
        results[5] as Either<Failure, List<InvalidReasonEntity>>;
    final teamsResult = results[6] as Either<Failure, List<TeamEntity>>;
    final rolesResult = results[7] as Either<Failure, List<RoleEntity>>;
    final permissionsResult =
        results[8] as Either<Failure, List<PermissionEntity>>;
    final invoiceTagsResult =
        results[9] as Either<Failure, List<InvoiceTagEntity>>;
    final productsResult = results[10] as Either<Failure, List<Product>>;
    final commentTypesResult =
        results[11] as Either<Failure, List<CommentTypeEntity>>;
    final citiesResult = results[12] as Either<Failure, List<CityEntity>>;

    return Right(
      AllLookups(
        clientStatuses: statusesResult.getOrElse(() => []),
        clientTags: tagsResult.getOrElse(() => []),
        regions: regionsResult.getOrElse(() => []),
        sources: sourcesResult.getOrElse(() => []),
        behaviors: behaviorsResult.getOrElse(() => []),
        invalidReasons: invalidReasonsResult.getOrElse(() => []),
        teams: teamsResult.getOrElse(() => []),
        roles: rolesResult.getOrElse(() => []),
        permissions: permissionsResult.getOrElse(() => []),
        invoiceTags: invoiceTagsResult.getOrElse(() => []),
        products: productsResult.getOrElse(() => []),
        commentTypes: commentTypesResult.getOrElse(() => []),
        cities: citiesResult.getOrElse(() => []),
      ),
    );
  }
}
