// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'person.dart';

class PersonMapper extends ClassMapperBase<Person> {
  PersonMapper._();

  static PersonMapper? _instance;
  static PersonMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PersonMapper._());
      PersonStatusMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Person';

  static String? _$name(Person v) => v.name;
  static const Field<Person, String> _f$name = Field('name', _$name, opt: true);
  static int _$age(Person v) => v.age;
  static const Field<Person, int> _f$age = Field(
    'age',
    _$age,
    opt: true,
    def: 0,
  );
  static PersonStatus _$status(Person v) => v.status;
  static const Field<Person, PersonStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );

  @override
  final MappableFields<Person> fields = const {
    #name: _f$name,
    #age: _f$age,
    #status: _f$status,
  };

  static Person _instantiate(DecodingData data) {
    return Person(
      name: data.dec(_f$name),
      age: data.dec(_f$age),
      status: data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Person fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Person>(map);
  }

  static Person fromJson(String json) {
    return ensureInitialized().decodeJson<Person>(json);
  }
}

mixin PersonMappable {
  String toJson() {
    return PersonMapper.ensureInitialized().encodeJson<Person>(this as Person);
  }

  Map<String, dynamic> toMap() {
    return PersonMapper.ensureInitialized().encodeMap<Person>(this as Person);
  }

  PersonCopyWith<Person, Person, Person> get copyWith =>
      _PersonCopyWithImpl<Person, Person>(this as Person, $identity, $identity);
  @override
  String toString() {
    return PersonMapper.ensureInitialized().stringifyValue(this as Person);
  }

  @override
  bool operator ==(Object other) {
    return PersonMapper.ensureInitialized().equalsValue(this as Person, other);
  }

  @override
  int get hashCode {
    return PersonMapper.ensureInitialized().hashValue(this as Person);
  }
}

extension PersonValueCopy<$R, $Out> on ObjectCopyWith<$R, Person, $Out> {
  PersonCopyWith<$R, Person, $Out> get $asPerson =>
      $base.as((v, t, t2) => _PersonCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PersonCopyWith<$R, $In extends Person, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  PersonStatusCopyWith<$R, PersonStatus, PersonStatus> get status;
  $R call({String? name, int? age, PersonStatus? status});
  PersonCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PersonCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Person, $Out>
    implements PersonCopyWith<$R, Person, $Out> {
  _PersonCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Person> $mapper = PersonMapper.ensureInitialized();
  @override
  PersonStatusCopyWith<$R, PersonStatus, PersonStatus> get status =>
      ($value.status as PersonStatus).copyWith.$chain((v) => call(status: v));
  @override
  $R call({Object? name = $none, int? age, Object? status = $none}) => $apply(
    FieldCopyWithData({
      if (name != $none) #name: name,
      if (age != null) #age: age,
      if (status != $none) #status: status,
    }),
  );
  @override
  Person $make(CopyWithData data) => Person(
    name: data.get(#name, or: $value.name),
    age: data.get(#age, or: $value.age),
    status: data.get(#status, or: $value.status),
  );

  @override
  PersonCopyWith<$R2, Person, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PersonCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class PersonStatusMapper extends ClassMapperBase<PersonStatus> {
  PersonStatusMapper._();

  static PersonStatusMapper? _instance;
  static PersonStatusMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PersonStatusMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PersonStatus';

  static bool _$isActive(PersonStatus v) => v.isActive;
  static const Field<PersonStatus, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    opt: true,
    def: true,
  );
  static List<String> _$labels(PersonStatus v) => v.labels;
  static const Field<PersonStatus, List<String>> _f$labels = Field(
    'labels',
    _$labels,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<PersonStatus> fields = const {
    #isActive: _f$isActive,
    #labels: _f$labels,
  };

  static PersonStatus _instantiate(DecodingData data) {
    return PersonStatus(
      isActive: data.dec(_f$isActive),
      labels: data.dec(_f$labels),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static PersonStatus fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PersonStatus>(map);
  }

  static PersonStatus fromJson(String json) {
    return ensureInitialized().decodeJson<PersonStatus>(json);
  }
}

mixin PersonStatusMappable {
  String toJson() {
    return PersonStatusMapper.ensureInitialized().encodeJson<PersonStatus>(
      this as PersonStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return PersonStatusMapper.ensureInitialized().encodeMap<PersonStatus>(
      this as PersonStatus,
    );
  }

  PersonStatusCopyWith<PersonStatus, PersonStatus, PersonStatus> get copyWith =>
      _PersonStatusCopyWithImpl<PersonStatus, PersonStatus>(
        this as PersonStatus,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return PersonStatusMapper.ensureInitialized().stringifyValue(
      this as PersonStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    return PersonStatusMapper.ensureInitialized().equalsValue(
      this as PersonStatus,
      other,
    );
  }

  @override
  int get hashCode {
    return PersonStatusMapper.ensureInitialized().hashValue(
      this as PersonStatus,
    );
  }
}

extension PersonStatusValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PersonStatus, $Out> {
  PersonStatusCopyWith<$R, PersonStatus, $Out> get $asPersonStatus =>
      $base.as((v, t, t2) => _PersonStatusCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PersonStatusCopyWith<$R, $In extends PersonStatus, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get labels;
  $R call({bool? isActive, List<String>? labels});
  PersonStatusCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PersonStatusCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PersonStatus, $Out>
    implements PersonStatusCopyWith<$R, PersonStatus, $Out> {
  _PersonStatusCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PersonStatus> $mapper =
      PersonStatusMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get labels =>
      ListCopyWith(
        $value.labels,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(labels: v),
      );
  @override
  $R call({bool? isActive, List<String>? labels}) => $apply(
    FieldCopyWithData({
      if (isActive != null) #isActive: isActive,
      if (labels != null) #labels: labels,
    }),
  );
  @override
  PersonStatus $make(CopyWithData data) => PersonStatus(
    isActive: data.get(#isActive, or: $value.isActive),
    labels: data.get(#labels, or: $value.labels),
  );

  @override
  PersonStatusCopyWith<$R2, PersonStatus, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _PersonStatusCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

