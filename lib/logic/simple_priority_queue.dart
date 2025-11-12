class SimplePriorityQueue<T> {
  final int Function(T a, T b) compare;
  final List<T> _heap = [];

  SimplePriorityQueue(this.compare);

  bool get isEmpty => _heap.isEmpty;
  bool get isNotEmpty => _heap.isNotEmpty;

  void add(T value) {
    _heap.add(value);
    _siftUp(_heap.length - 1);
  }

  T removeFirst() {
    final first = _heap.first;
    final last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _siftDown(0);
    }
    return first;
  }

  void _siftUp(int i) {
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (compare(_heap[i], _heap[parent]) < 0) {
        final tmp = _heap[parent];
        _heap[parent] = _heap[i];
        _heap[i] = tmp;
        i = parent;
      } else {
        break;
      }
    }
  }

  void _siftDown(int i) {
    final n = _heap.length;
    while (true) {
      final left = i * 2 + 1;
      final right = i * 2 + 2;
      int smallest = i;
      if (left < n && compare(_heap[left], _heap[smallest]) < 0) {
        smallest = left;
      }
      if (right < n && compare(_heap[right], _heap[smallest]) < 0) {
        smallest = right;
      }
      if (smallest == i) break;
      final tmp = _heap[smallest];
      _heap[smallest] = _heap[i];
      _heap[i] = tmp;
      i = smallest;
    }
  }
}
