// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssetsDataNotifier)
final assetsDataProvider = AssetsDataNotifierProvider._();

final class AssetsDataNotifierProvider
    extends $StreamNotifierProvider<AssetsDataNotifier, AssetsData> {
  AssetsDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetsDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetsDataNotifierHash();

  @$internal
  @override
  AssetsDataNotifier create() => AssetsDataNotifier();
}

String _$assetsDataNotifierHash() =>
    r'fe6e154b4cbfb0c5536129eb5722157b0aaefcd1';

abstract class _$AssetsDataNotifier extends $StreamNotifier<AssetsData> {
  Stream<AssetsData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AssetsData>, AssetsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AssetsData>, AssetsData>,
              AsyncValue<AssetsData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BasicInfoDataNotifier)
final basicInfoDataProvider = BasicInfoDataNotifierProvider._();

final class BasicInfoDataNotifierProvider
    extends $StreamNotifierProvider<BasicInfoDataNotifier, BasicInfoData> {
  BasicInfoDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'basicInfoDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$basicInfoDataNotifierHash();

  @$internal
  @override
  BasicInfoDataNotifier create() => BasicInfoDataNotifier();
}

String _$basicInfoDataNotifierHash() =>
    r'a8508a15a63b62fe60749b48f66d9f350d40d20c';

abstract class _$BasicInfoDataNotifier extends $StreamNotifier<BasicInfoData> {
  Stream<BasicInfoData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BasicInfoData>, BasicInfoData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BasicInfoData>, BasicInfoData>,
              AsyncValue<BasicInfoData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 出費額計算：proposeDate までの毎月許容出費額を計算

@ProviderFor(FinancialCalculation)
final financialCalculationProvider = FinancialCalculationProvider._();

/// 出費額計算：proposeDate までの毎月許容出費額を計算
final class FinancialCalculationProvider
    extends $NotifierProvider<FinancialCalculation, Map<String, dynamic>> {
  /// 出費額計算：proposeDate までの毎月許容出費額を計算
  FinancialCalculationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialCalculationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialCalculationHash();

  @$internal
  @override
  FinancialCalculation create() => FinancialCalculation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>>(value),
    );
  }
}

String _$financialCalculationHash() =>
    r'144437dd7622c64b9616bdddd9f5a0d48759bc28';

/// 出費額計算：proposeDate までの毎月許容出費額を計算

abstract class _$FinancialCalculation extends $Notifier<Map<String, dynamic>> {
  Map<String, dynamic> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, dynamic>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, dynamic>, Map<String, dynamic>>,
              Map<String, dynamic>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 時期計算：各 ExpenseItem を賄える時期を計算（order 順、累積）
///
/// 戻り値: List<Map> = [
///   {'item': ExpenseItem, 'affordableDate': 'yyyy/mm' or null},
/// ]

@ProviderFor(ItemAffordabilityCalculation)
final itemAffordabilityCalculationProvider =
    ItemAffordabilityCalculationProvider._();

/// 時期計算：各 ExpenseItem を賄える時期を計算（order 順、累積）
///
/// 戻り値: List<Map> = [
///   {'item': ExpenseItem, 'affordableDate': 'yyyy/mm' or null},
/// ]
final class ItemAffordabilityCalculationProvider
    extends
        $NotifierProvider<
          ItemAffordabilityCalculation,
          List<Map<String, dynamic>>
        > {
  /// 時期計算：各 ExpenseItem を賄える時期を計算（order 順、累積）
  ///
  /// 戻り値: List<Map> = [
  ///   {'item': ExpenseItem, 'affordableDate': 'yyyy/mm' or null},
  /// ]
  ItemAffordabilityCalculationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemAffordabilityCalculationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemAffordabilityCalculationHash();

  @$internal
  @override
  ItemAffordabilityCalculation create() => ItemAffordabilityCalculation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Map<String, dynamic>>>(value),
    );
  }
}

String _$itemAffordabilityCalculationHash() =>
    r'9051beb410d538a626d5ca43cb7053bee2532f38';

/// 時期計算：各 ExpenseItem を賄える時期を計算（order 順、累積）
///
/// 戻り値: List<Map> = [
///   {'item': ExpenseItem, 'affordableDate': 'yyyy/mm' or null},
/// ]

abstract class _$ItemAffordabilityCalculation
    extends $Notifier<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<List<Map<String, dynamic>>, List<Map<String, dynamic>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<Map<String, dynamic>>,
                List<Map<String, dynamic>>
              >,
              List<Map<String, dynamic>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
