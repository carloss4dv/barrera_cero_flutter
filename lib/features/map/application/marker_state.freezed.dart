// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkerState {

 DataState<List<MarkerModel>> get nearbyMarkersState; DataState<MarkerModel> get currentLocationState; DataState<MarkerModel> get selectedMarkerState; DataState<List<LatLng>> get routeState; double get searchRadius;
/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerStateCopyWith<MarkerState> get copyWith => _$MarkerStateCopyWithImpl<MarkerState>(this as MarkerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerState&&(identical(other.nearbyMarkersState, nearbyMarkersState) || other.nearbyMarkersState == nearbyMarkersState)&&(identical(other.currentLocationState, currentLocationState) || other.currentLocationState == currentLocationState)&&(identical(other.selectedMarkerState, selectedMarkerState) || other.selectedMarkerState == selectedMarkerState)&&(identical(other.routeState, routeState) || other.routeState == routeState)&&(identical(other.searchRadius, searchRadius) || other.searchRadius == searchRadius));
}


@override
int get hashCode => Object.hash(runtimeType,nearbyMarkersState,currentLocationState,selectedMarkerState,routeState,searchRadius);

@override
String toString() {
  return 'MarkerState(nearbyMarkersState: $nearbyMarkersState, currentLocationState: $currentLocationState, selectedMarkerState: $selectedMarkerState, routeState: $routeState, searchRadius: $searchRadius)';
}


}

/// @nodoc
abstract mixin class $MarkerStateCopyWith<$Res>  {
  factory $MarkerStateCopyWith(MarkerState value, $Res Function(MarkerState) _then) = _$MarkerStateCopyWithImpl;
@useResult
$Res call({
 DataState<List<MarkerModel>> nearbyMarkersState, DataState<MarkerModel> currentLocationState, DataState<MarkerModel> selectedMarkerState, DataState<List<LatLng>> routeState, double searchRadius
});


$DataStateCopyWith<List<MarkerModel>, $Res> get nearbyMarkersState;$DataStateCopyWith<MarkerModel, $Res> get currentLocationState;$DataStateCopyWith<MarkerModel, $Res> get selectedMarkerState;$DataStateCopyWith<List<LatLng>, $Res> get routeState;

}
/// @nodoc
class _$MarkerStateCopyWithImpl<$Res>
    implements $MarkerStateCopyWith<$Res> {
  _$MarkerStateCopyWithImpl(this._self, this._then);

  final MarkerState _self;
  final $Res Function(MarkerState) _then;

/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nearbyMarkersState = null,Object? currentLocationState = null,Object? selectedMarkerState = null,Object? routeState = null,Object? searchRadius = null,}) {
  return _then(_self.copyWith(
nearbyMarkersState: null == nearbyMarkersState ? _self.nearbyMarkersState : nearbyMarkersState // ignore: cast_nullable_to_non_nullable
as DataState<List<MarkerModel>>,currentLocationState: null == currentLocationState ? _self.currentLocationState : currentLocationState // ignore: cast_nullable_to_non_nullable
as DataState<MarkerModel>,selectedMarkerState: null == selectedMarkerState ? _self.selectedMarkerState : selectedMarkerState // ignore: cast_nullable_to_non_nullable
as DataState<MarkerModel>,routeState: null == routeState ? _self.routeState : routeState // ignore: cast_nullable_to_non_nullable
as DataState<List<LatLng>>,searchRadius: null == searchRadius ? _self.searchRadius : searchRadius // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<List<MarkerModel>, $Res> get nearbyMarkersState {
  
  return $DataStateCopyWith<List<MarkerModel>, $Res>(_self.nearbyMarkersState, (value) {
    return _then(_self.copyWith(nearbyMarkersState: value));
  });
}/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<MarkerModel, $Res> get currentLocationState {
  
  return $DataStateCopyWith<MarkerModel, $Res>(_self.currentLocationState, (value) {
    return _then(_self.copyWith(currentLocationState: value));
  });
}/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<MarkerModel, $Res> get selectedMarkerState {
  
  return $DataStateCopyWith<MarkerModel, $Res>(_self.selectedMarkerState, (value) {
    return _then(_self.copyWith(selectedMarkerState: value));
  });
}/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<List<LatLng>, $Res> get routeState {
  
  return $DataStateCopyWith<List<LatLng>, $Res>(_self.routeState, (value) {
    return _then(_self.copyWith(routeState: value));
  });
}
}


/// @nodoc


class _MarkerState extends MarkerState {
  const _MarkerState({required this.nearbyMarkersState, required this.currentLocationState, required this.selectedMarkerState, required this.routeState, this.searchRadius = 1000.0}): super._();
  

@override final  DataState<List<MarkerModel>> nearbyMarkersState;
@override final  DataState<MarkerModel> currentLocationState;
@override final  DataState<MarkerModel> selectedMarkerState;
@override final  DataState<List<LatLng>> routeState;
@override@JsonKey() final  double searchRadius;

/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkerStateCopyWith<_MarkerState> get copyWith => __$MarkerStateCopyWithImpl<_MarkerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkerState&&(identical(other.nearbyMarkersState, nearbyMarkersState) || other.nearbyMarkersState == nearbyMarkersState)&&(identical(other.currentLocationState, currentLocationState) || other.currentLocationState == currentLocationState)&&(identical(other.selectedMarkerState, selectedMarkerState) || other.selectedMarkerState == selectedMarkerState)&&(identical(other.routeState, routeState) || other.routeState == routeState)&&(identical(other.searchRadius, searchRadius) || other.searchRadius == searchRadius));
}


@override
int get hashCode => Object.hash(runtimeType,nearbyMarkersState,currentLocationState,selectedMarkerState,routeState,searchRadius);

@override
String toString() {
  return 'MarkerState(nearbyMarkersState: $nearbyMarkersState, currentLocationState: $currentLocationState, selectedMarkerState: $selectedMarkerState, routeState: $routeState, searchRadius: $searchRadius)';
}


}

/// @nodoc
abstract mixin class _$MarkerStateCopyWith<$Res> implements $MarkerStateCopyWith<$Res> {
  factory _$MarkerStateCopyWith(_MarkerState value, $Res Function(_MarkerState) _then) = __$MarkerStateCopyWithImpl;
@override @useResult
$Res call({
 DataState<List<MarkerModel>> nearbyMarkersState, DataState<MarkerModel> currentLocationState, DataState<MarkerModel> selectedMarkerState, DataState<List<LatLng>> routeState, double searchRadius
});


@override $DataStateCopyWith<List<MarkerModel>, $Res> get nearbyMarkersState;@override $DataStateCopyWith<MarkerModel, $Res> get currentLocationState;@override $DataStateCopyWith<MarkerModel, $Res> get selectedMarkerState;@override $DataStateCopyWith<List<LatLng>, $Res> get routeState;

}
/// @nodoc
class __$MarkerStateCopyWithImpl<$Res>
    implements _$MarkerStateCopyWith<$Res> {
  __$MarkerStateCopyWithImpl(this._self, this._then);

  final _MarkerState _self;
  final $Res Function(_MarkerState) _then;

/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nearbyMarkersState = null,Object? currentLocationState = null,Object? selectedMarkerState = null,Object? routeState = null,Object? searchRadius = null,}) {
  return _then(_MarkerState(
nearbyMarkersState: null == nearbyMarkersState ? _self.nearbyMarkersState : nearbyMarkersState // ignore: cast_nullable_to_non_nullable
as DataState<List<MarkerModel>>,currentLocationState: null == currentLocationState ? _self.currentLocationState : currentLocationState // ignore: cast_nullable_to_non_nullable
as DataState<MarkerModel>,selectedMarkerState: null == selectedMarkerState ? _self.selectedMarkerState : selectedMarkerState // ignore: cast_nullable_to_non_nullable
as DataState<MarkerModel>,routeState: null == routeState ? _self.routeState : routeState // ignore: cast_nullable_to_non_nullable
as DataState<List<LatLng>>,searchRadius: null == searchRadius ? _self.searchRadius : searchRadius // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<List<MarkerModel>, $Res> get nearbyMarkersState {
  
  return $DataStateCopyWith<List<MarkerModel>, $Res>(_self.nearbyMarkersState, (value) {
    return _then(_self.copyWith(nearbyMarkersState: value));
  });
}/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<MarkerModel, $Res> get currentLocationState {
  
  return $DataStateCopyWith<MarkerModel, $Res>(_self.currentLocationState, (value) {
    return _then(_self.copyWith(currentLocationState: value));
  });
}/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<MarkerModel, $Res> get selectedMarkerState {
  
  return $DataStateCopyWith<MarkerModel, $Res>(_self.selectedMarkerState, (value) {
    return _then(_self.copyWith(selectedMarkerState: value));
  });
}/// Create a copy of MarkerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataStateCopyWith<List<LatLng>, $Res> get routeState {
  
  return $DataStateCopyWith<List<LatLng>, $Res>(_self.routeState, (value) {
    return _then(_self.copyWith(routeState: value));
  });
}
}

/// @nodoc
mixin _$DataState<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DataState<$T>()';
}


}

/// @nodoc
class $DataStateCopyWith<T,$Res>  {
$DataStateCopyWith(DataState<T> _, $Res Function(DataState<T>) __);
}


/// @nodoc


class _Idle<T> extends DataState<T> {
  const _Idle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DataState<$T>.idle()';
}


}




/// @nodoc


class _Loading<T> extends DataState<T> {
  const _Loading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DataState<$T>.loading()';
}


}




/// @nodoc


class _Error<T> extends DataState<T> {
  const _Error([this.message]): super._();
  

 final  String? message;

/// Create a copy of DataState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<T, _Error<T>> get copyWith => __$ErrorCopyWithImpl<T, _Error<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DataState<$T>.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<T,$Res> implements $DataStateCopyWith<T, $Res> {
  factory _$ErrorCopyWith(_Error<T> value, $Res Function(_Error<T>) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<T,$Res>
    implements _$ErrorCopyWith<T, $Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error<T> _self;
  final $Res Function(_Error<T>) _then;

/// Create a copy of DataState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(_Error<T>(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Success<T> extends DataState<T> {
  const _Success(this.data): super._();
  

 final  T data;

/// Create a copy of DataState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<T, _Success<T>> get copyWith => __$SuccessCopyWithImpl<T, _Success<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'DataState<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<T,$Res> implements $DataStateCopyWith<T, $Res> {
  factory _$SuccessCopyWith(_Success<T> value, $Res Function(_Success<T>) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class __$SuccessCopyWithImpl<T,$Res>
    implements _$SuccessCopyWith<T, $Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success<T> _self;
  final $Res Function(_Success<T>) _then;

/// Create a copy of DataState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(_Success<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

// dart format on
