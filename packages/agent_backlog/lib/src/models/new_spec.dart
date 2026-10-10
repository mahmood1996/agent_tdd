/// Abstract interface representing an unpersisted spec item draft.
///
/// Contains all fields needed to describe a spec before it is assigned
/// a persistent [id] by a [SpecStore]. See [Spec] for the persisted form.
abstract interface class NewSpec {
  String get title;
  String get status;
  String get description;
  Map<String, dynamic> get metadata;
}
