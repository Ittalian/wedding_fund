// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'basic_info_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BasicInfoData {

 String? get forecastStartDate;// yyyy/mm/dd 形式
 int get monthlyExpense;// 月の固定出費
 List<ExpenseItem> get expenses; int get savingsGoal; bool get alwaysKeepSavingsGoal;
/// Create a copy of BasicInfoData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BasicInfoDataCopyWith<BasicInfoData> get copyWith => _$BasicInfoDataCopyWithImpl<BasicInfoData>(this as BasicInfoData, _$identity);

  /// Serializes this BasicInfoData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BasicInfoData&&(identical(other.forecastStartDate, forecastStartDate) || other.forecastStartDate == forecastStartDate)&&(identical(other.monthlyExpense, monthlyExpense) || other.monthlyExpense == monthlyExpense)&&const DeepCollectionEquality().equals(other.expenses, expenses)&&(identical(other.savingsGoal, savingsGoal) || other.savingsGoal == savingsGoal)&&(identical(other.alwaysKeepSavingsGoal, alwaysKeepSavingsGoal) || other.alwaysKeepSavingsGoal == alwaysKeepSavingsGoal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forecastStartDate,monthlyExpense,const DeepCollectionEquality().hash(expenses),savingsGoal,alwaysKeepSavingsGoal);

@override
String toString() {
  return 'BasicInfoData(forecastStartDate: $forecastStartDate, monthlyExpense: $monthlyExpense, expenses: $expenses, savingsGoal: $savingsGoal, alwaysKeepSavingsGoal: $alwaysKeepSavingsGoal)';
}


}

/// @nodoc
abstract mixin class $BasicInfoDataCopyWith<$Res>  {
  factory $BasicInfoDataCopyWith(BasicInfoData value, $Res Function(BasicInfoData) _then) = _$BasicInfoDataCopyWithImpl;
@useResult
$Res call({
 String? forecastStartDate, int monthlyExpense, List<ExpenseItem> expenses, int savingsGoal, bool alwaysKeepSavingsGoal
});




}
/// @nodoc
class _$BasicInfoDataCopyWithImpl<$Res>
    implements $BasicInfoDataCopyWith<$Res> {
  _$BasicInfoDataCopyWithImpl(this._self, this._then);

  final BasicInfoData _self;
  final $Res Function(BasicInfoData) _then;

/// Create a copy of BasicInfoData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? forecastStartDate = freezed,Object? monthlyExpense = null,Object? expenses = null,Object? savingsGoal = null,Object? alwaysKeepSavingsGoal = null,}) {
  return _then(_self.copyWith(
forecastStartDate: freezed == forecastStartDate ? _self.forecastStartDate : forecastStartDate // ignore: cast_nullable_to_non_nullable
as String?,monthlyExpense: null == monthlyExpense ? _self.monthlyExpense : monthlyExpense // ignore: cast_nullable_to_non_nullable
as int,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseItem>,savingsGoal: null == savingsGoal ? _self.savingsGoal : savingsGoal // ignore: cast_nullable_to_non_nullable
as int,alwaysKeepSavingsGoal: null == alwaysKeepSavingsGoal ? _self.alwaysKeepSavingsGoal : alwaysKeepSavingsGoal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BasicInfoData].
extension BasicInfoDataPatterns on BasicInfoData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BasicInfoData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BasicInfoData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BasicInfoData value)  $default,){
final _that = this;
switch (_that) {
case _BasicInfoData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BasicInfoData value)?  $default,){
final _that = this;
switch (_that) {
case _BasicInfoData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? forecastStartDate,  int monthlyExpense,  List<ExpenseItem> expenses,  int savingsGoal,  bool alwaysKeepSavingsGoal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BasicInfoData() when $default != null:
return $default(_that.forecastStartDate,_that.monthlyExpense,_that.expenses,_that.savingsGoal,_that.alwaysKeepSavingsGoal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? forecastStartDate,  int monthlyExpense,  List<ExpenseItem> expenses,  int savingsGoal,  bool alwaysKeepSavingsGoal)  $default,) {final _that = this;
switch (_that) {
case _BasicInfoData():
return $default(_that.forecastStartDate,_that.monthlyExpense,_that.expenses,_that.savingsGoal,_that.alwaysKeepSavingsGoal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? forecastStartDate,  int monthlyExpense,  List<ExpenseItem> expenses,  int savingsGoal,  bool alwaysKeepSavingsGoal)?  $default,) {final _that = this;
switch (_that) {
case _BasicInfoData() when $default != null:
return $default(_that.forecastStartDate,_that.monthlyExpense,_that.expenses,_that.savingsGoal,_that.alwaysKeepSavingsGoal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BasicInfoData extends BasicInfoData {
  const _BasicInfoData({this.forecastStartDate, this.monthlyExpense = 0, final  List<ExpenseItem> expenses = const [], this.savingsGoal = 0, this.alwaysKeepSavingsGoal = false}): _expenses = expenses,super._();
  factory _BasicInfoData.fromJson(Map<String, dynamic> json) => _$BasicInfoDataFromJson(json);

@override final  String? forecastStartDate;
// yyyy/mm/dd 形式
@override@JsonKey() final  int monthlyExpense;
// 月の固定出費
 final  List<ExpenseItem> _expenses;
// 月の固定出費
@override@JsonKey() List<ExpenseItem> get expenses {
  if (_expenses is EqualUnmodifiableListView) return _expenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenses);
}

@override@JsonKey() final  int savingsGoal;
@override@JsonKey() final  bool alwaysKeepSavingsGoal;

/// Create a copy of BasicInfoData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BasicInfoDataCopyWith<_BasicInfoData> get copyWith => __$BasicInfoDataCopyWithImpl<_BasicInfoData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BasicInfoDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BasicInfoData&&(identical(other.forecastStartDate, forecastStartDate) || other.forecastStartDate == forecastStartDate)&&(identical(other.monthlyExpense, monthlyExpense) || other.monthlyExpense == monthlyExpense)&&const DeepCollectionEquality().equals(other._expenses, _expenses)&&(identical(other.savingsGoal, savingsGoal) || other.savingsGoal == savingsGoal)&&(identical(other.alwaysKeepSavingsGoal, alwaysKeepSavingsGoal) || other.alwaysKeepSavingsGoal == alwaysKeepSavingsGoal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,forecastStartDate,monthlyExpense,const DeepCollectionEquality().hash(_expenses),savingsGoal,alwaysKeepSavingsGoal);

@override
String toString() {
  return 'BasicInfoData(forecastStartDate: $forecastStartDate, monthlyExpense: $monthlyExpense, expenses: $expenses, savingsGoal: $savingsGoal, alwaysKeepSavingsGoal: $alwaysKeepSavingsGoal)';
}


}

/// @nodoc
abstract mixin class _$BasicInfoDataCopyWith<$Res> implements $BasicInfoDataCopyWith<$Res> {
  factory _$BasicInfoDataCopyWith(_BasicInfoData value, $Res Function(_BasicInfoData) _then) = __$BasicInfoDataCopyWithImpl;
@override @useResult
$Res call({
 String? forecastStartDate, int monthlyExpense, List<ExpenseItem> expenses, int savingsGoal, bool alwaysKeepSavingsGoal
});




}
/// @nodoc
class __$BasicInfoDataCopyWithImpl<$Res>
    implements _$BasicInfoDataCopyWith<$Res> {
  __$BasicInfoDataCopyWithImpl(this._self, this._then);

  final _BasicInfoData _self;
  final $Res Function(_BasicInfoData) _then;

/// Create a copy of BasicInfoData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? forecastStartDate = freezed,Object? monthlyExpense = null,Object? expenses = null,Object? savingsGoal = null,Object? alwaysKeepSavingsGoal = null,}) {
  return _then(_BasicInfoData(
forecastStartDate: freezed == forecastStartDate ? _self.forecastStartDate : forecastStartDate // ignore: cast_nullable_to_non_nullable
as String?,monthlyExpense: null == monthlyExpense ? _self.monthlyExpense : monthlyExpense // ignore: cast_nullable_to_non_nullable
as int,expenses: null == expenses ? _self._expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<ExpenseItem>,savingsGoal: null == savingsGoal ? _self.savingsGoal : savingsGoal // ignore: cast_nullable_to_non_nullable
as int,alwaysKeepSavingsGoal: null == alwaysKeepSavingsGoal ? _self.alwaysKeepSavingsGoal : alwaysKeepSavingsGoal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
