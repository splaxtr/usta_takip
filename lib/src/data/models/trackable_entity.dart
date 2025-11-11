/// Base mixin that adds lifecycle tracking information to Hive entities.
mixin TrackableEntity {
  bool isDeleted = false;
  bool isArchived = false;
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
  DateTime? deletedAt;
}
