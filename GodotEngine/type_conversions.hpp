template<typename T>
Vector<T> vectorize(Set<T> const& set) {
	Vector<T> vec;

	for (auto const *E = set.front(); E; E = E->next()) {
		vec.push_back(E->get());
	}

	return vec;
}

template<typename K, typename V>
Vector<Pair<K,V>> vectorize(Map<K,V> const& map) {
	Vector<Pair<K,V>> vec;

	for (auto const *E = map.front(); E; E = E->next()) {
		vec.push_back({ E->key(), E->value() });
	}

	return vec;
}