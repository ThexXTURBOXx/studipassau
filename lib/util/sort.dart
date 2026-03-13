extension ComparatorExtension<T> on Comparator<T> {
  Comparator<T> then(Comparator<T> other) => (a, b) {
    final comp = this(a, b);
    return comp != 0 ? comp : other(a, b);
  };

  Comparator<T> thenBy<C extends Comparable<C>>(C Function(T) key) =>
      then(compareBy(key));

  Comparator<T> thenByNullable<C extends Comparable<C>>(
    C? Function(T) key, {
    bool nullsFirst = false,
  }) => then(compareByNullable(key, nullsFirst: nullsFirst));
}

Comparator<T> compareBy<T, C extends Comparable<C>>(C Function(T) key) =>
    (a, b) => key(a).compareTo(key(b));

Comparator<T> compareByNullable<T, C extends Comparable<C>>(
  C? Function(T) key, {
  bool nullsFirst = false,
}) => (a, b) {
  final v1 = key(a);
  final v2 = key(b);
  if (v1 == null && v2 == null) return 0;
  if (v1 == null) return nullsFirst ? -1 : 1;
  if (v2 == null) return nullsFirst ? 1 : -1;
  return v1.compareTo(v2);
};
