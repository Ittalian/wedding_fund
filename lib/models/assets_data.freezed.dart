// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assets_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetsData {

 int get currentSavings; int get monthlyIncome; int get incomeDate;// 平均収入が入る日 (1~31)
 int get bonusAmount; List<int> get bonusMonths;// ボーナスの支給月 (例: [6, 12])
 int get bonusDate;
/// Create a copy of AssetsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetsDataCopyWith<AssetsData> get copyWith => _$AssetsDataCopyWithImpl<AssetsData>(this as AssetsData, _$identity);

  /// Serializes this AssetsData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetsData&&(identical(other.currentSavings, currentSavings) || other.currentSavings == currentSavings)&&(identical(other.monthlyIncome, monthlyIncome) || other.monthlyIncome == monthlyIncome)&&(identical(other.incomeDate, incomeDate) || other.incomeDate == incomeDate)&&(identical(other.bonusAmount, bonusAmount) || other.bonusAmount == bonusAmount)&&const DeepCollectionEquality().equals(other.bonusMonths, bonusMonths)&&(identical(other.bonusDate, bonusDate) || other.bonusDate == bonusDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentSavings,monthlyIncome,incomeDate,bonusAmount,const DeepCollectionEquality().hash(bonusMonths),bonusDate);

@override
String toString() {
  return 'AssetsData(currentSavings: $currentSavings, monthlyIncome: $monthlyIncome, incomeDate: $incomeDate, bonusAmount: $bonusAmount, bonusMonths: $bonusMonths, bonusDate: $bonusDate)';
}


}

/// @nodoc
abstract mixin class $AssetsDataCopyWith<$Res>  {
  factory $AssetsDataCopyWith(AssetsData value, $Res Function(AssetsData) _then) = _$AssetsDataCopyWithImpl;
@useResult
$Res call({
 int currentSavings, int monthlyIncome, int incomeDate, int bonusAmount, List<int> bonusMonths, int bonusDate
});




}
/// @nodoc
class _$AssetsDataCopyWithImpl<$Res>
    implements $AssetsDataCopyWith<$Res> {
  _$AssetsDataCopyWithImpl(this._self, this._then);

  final AssetsData _self;
  final $Res Function(AssetsData) _then;

/// Create a copy of AssetsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentSavings = null,Object? monthlyIncome = null,Object? incomeDate = null,Object? bonusAmount = null,Object? bonusMonths = null,Object? bonusDate = null,}) {
  return _then(_self.copyWith(
currentSavings: null == currentSavings ? _self.currentSavings : currentSavings // ignore: cast_nullable_to_non_nullable
as int,monthlyIncome: null == monthlyIncome ? _self.monthlyIncome : monthlyIncome // ignore: cast_nullable_to_non_nullable
as int,incomeDate: null == incomeDate ? _self.incomeDate : incomeDate // ignore: cast_nullable_to_non_nullable
as int,bonusAmount: null == bonusAmount ? _self.bonusAmount : bonusAmount // ignore: cast_nullable_to_non_nullable
as int,bonusMonths: null == bonusMonths ? _self.bonusMonths : bonusMonths // ignore: cast_nullable_to_non_nullable
as List<int>,bonusDate: null == bonusDate ? _self.bonusDate : bonusDate // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetsData].
extension AssetsDataPatterns on AssetsData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetsData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetsData value)  $default,){
final _that = this;
switch (_that) {
case _AssetsData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetsData value)?  $default,){
final _that = this;
switch (_that) {
case _AssetsData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentSavings,  int monthlyIncome,  int incomeDate,  int bonusAmount,  List<int> bonusMonths,  int bonusDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetsData() when $default != null:
return $default(_that.currentSavings,_that.monthlyIncome,_that.incomeDate,_that.bonusAmount,_that.bonusMonths,_that.bonusDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentSavings,  int monthlyIncome,  int incomeDate,  int bonusAmount,  List<int> bonusMonths,  int bonusDate)  $default,) {final _that = this;
switch (_that) {
case _AssetsData():
return $default(_that.currentSavings,_that.monthlyIncome,_that.incomeDate,_that.bonusAmount,_that.bonusMonths,_that.bonusDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentSavings,  int monthlyIncome,  int incomeDate,  int bonusAmount,  List<int> bonusMonths,  int bonusDate)?  $default,) {final _that = this;
switch (_that) {
case _AssetsData() when $default != null:
return $default(_that.currentSavings,_that.monthlyIncome,_that.incomeDate,_that.bonusAmount,_that.bonusMonths,_that.bonusDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetsData implements AssetsData {
  const _AssetsData({this.currentSavings = 0, this.monthlyIncome = 0, this.incomeDate = 25, this.bonusAmount = 0, final  List<int> bonusMonths = const [], this.bonusDate = 10}): _bonusMonths = bonusMonths;
  factory _AssetsData.fromJson(Map<String, dynamic> json) => _$AssetsDataFromJson(json);

@override@JsonKey() final  int currentSavings;
@override@JsonKey() final  int monthlyIncome;
@override@JsonKey() final  int incomeDate;
// 平均収入が入る日 (1~31)
@override@JsonKey() final  int bonusAmount;
 final  List<int> _bonusMonths;
@override@JsonKey() List<int> get bonusMonths {
  if (_bonusMonths is EqualUnmodifiableListView) return _bonusMonths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bonusMonths);
}

// ボーナスの支給月 (例: [6, 12])
@override@JsonKey() final  int bonusDate;

/// Create a copy of AssetsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetsDataCopyWith<_AssetsData> get copyWith => __$AssetsDataCopyWithImpl<_AssetsData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetsDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetsData&&(identical(other.currentSavings, currentSavings) || other.currentSavings == currentSavings)&&(identical(other.monthlyIncome, monthlyIncome) || other.monthlyIncome == monthlyIncome)&&(identical(other.incomeDate, incomeDate) || other.incomeDate == incomeDate)&&(identical(other.bonusAmount, bonusAmount) || other.bonusAmount == bonusAmount)&&const DeepCollectionEquality().equals(other._bonusMonths, _bonusMonths)&&(identical(other.bonusDate, bonusDate) || other.bonusDate == bonusDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentSavings,monthlyIncome,incomeDate,bonusAmount,const DeepCollectionEquality().hash(_bonusMonths),bonusDate);

@override
String toString() {
  return 'AssetsData(currentSavings: $currentSavings, monthlyIncome: $monthlyIncome, incomeDate: $incomeDate, bonusAmount: $bonusAmount, bonusMonths: $bonusMonths, bonusDate: $bonusDate)';
}


}

/// @nodoc
abstract mixin class _$AssetsDataCopyWith<$Res> implements $AssetsDataCopyWith<$Res> {
  factory _$AssetsDataCopyWith(_AssetsData value, $Res Function(_AssetsData) _then) = __$AssetsDataCopyWithImpl;
@override @useResult
$Res call({
 int currentSavings, int monthlyIncome, int incomeDate, int bonusAmount, List<int> bonusMonths, int bonusDate
});




}
/// @nodoc
class __$AssetsDataCopyWithImpl<$Res>
    implements _$AssetsDataCopyWith<$Res> {
  __$AssetsDataCopyWithImpl(this._self, this._then);

  final _AssetsData _self;
  final $Res Function(_AssetsData) _then;

/// Create a copy of AssetsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentSavings = null,Object? monthlyIncome = null,Object? incomeDate = null,Object? bonusAmount = null,Object? bonusMonths = null,Object? bonusDate = null,}) {
  return _then(_AssetsData(
currentSavings: null == currentSavings ? _self.currentSavings : currentSavings // ignore: cast_nullable_to_non_nullable
as int,monthlyIncome: null == monthlyIncome ? _self.monthlyIncome : monthlyIncome // ignore: cast_nullable_to_non_nullable
as int,incomeDate: null == incomeDate ? _self.incomeDate : incomeDate // ignore: cast_nullable_to_non_nullable
as int,bonusAmount: null == bonusAmount ? _self.bonusAmount : bonusAmount // ignore: cast_nullable_to_non_nullable
as int,bonusMonths: null == bonusMonths ? _self._bonusMonths : bonusMonths // ignore: cast_nullable_to_non_nullable
as List<int>,bonusDate: null == bonusDate ? _self.bonusDate : bonusDate // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
