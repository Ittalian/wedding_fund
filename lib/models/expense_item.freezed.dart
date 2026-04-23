// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseItem {

 String get id; String get name; int get cost; int get order; String? get targetDate;
/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseItemCopyWith<ExpenseItem> get copyWith => _$ExpenseItemCopyWithImpl<ExpenseItem>(this as ExpenseItem, _$identity);

  /// Serializes this ExpenseItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.order, order) || other.order == order)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cost,order,targetDate);

@override
String toString() {
  return 'ExpenseItem(id: $id, name: $name, cost: $cost, order: $order, targetDate: $targetDate)';
}


}

/// @nodoc
abstract mixin class $ExpenseItemCopyWith<$Res>  {
  factory $ExpenseItemCopyWith(ExpenseItem value, $Res Function(ExpenseItem) _then) = _$ExpenseItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, int cost, int order, String? targetDate
});




}
/// @nodoc
class _$ExpenseItemCopyWithImpl<$Res>
    implements $ExpenseItemCopyWith<$Res> {
  _$ExpenseItemCopyWithImpl(this._self, this._then);

  final ExpenseItem _self;
  final $Res Function(ExpenseItem) _then;

/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cost = null,Object? order = null,Object? targetDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseItem].
extension ExpenseItemPatterns on ExpenseItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseItem value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseItem value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int cost,  int order,  String? targetDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
return $default(_that.id,_that.name,_that.cost,_that.order,_that.targetDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int cost,  int order,  String? targetDate)  $default,) {final _that = this;
switch (_that) {
case _ExpenseItem():
return $default(_that.id,_that.name,_that.cost,_that.order,_that.targetDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int cost,  int order,  String? targetDate)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
return $default(_that.id,_that.name,_that.cost,_that.order,_that.targetDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseItem implements ExpenseItem {
  const _ExpenseItem({required this.id, required this.name, required this.cost, required this.order, this.targetDate});
  factory _ExpenseItem.fromJson(Map<String, dynamic> json) => _$ExpenseItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  int cost;
@override final  int order;
@override final  String? targetDate;

/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseItemCopyWith<_ExpenseItem> get copyWith => __$ExpenseItemCopyWithImpl<_ExpenseItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.order, order) || other.order == order)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cost,order,targetDate);

@override
String toString() {
  return 'ExpenseItem(id: $id, name: $name, cost: $cost, order: $order, targetDate: $targetDate)';
}


}

/// @nodoc
abstract mixin class _$ExpenseItemCopyWith<$Res> implements $ExpenseItemCopyWith<$Res> {
  factory _$ExpenseItemCopyWith(_ExpenseItem value, $Res Function(_ExpenseItem) _then) = __$ExpenseItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int cost, int order, String? targetDate
});




}
/// @nodoc
class __$ExpenseItemCopyWithImpl<$Res>
    implements _$ExpenseItemCopyWith<$Res> {
  __$ExpenseItemCopyWithImpl(this._self, this._then);

  final _ExpenseItem _self;
  final $Res Function(_ExpenseItem) _then;

/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cost = null,Object? order = null,Object? targetDate = freezed,}) {
  return _then(_ExpenseItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
