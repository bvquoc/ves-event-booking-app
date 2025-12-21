class AppImages {
  // Map cho Category
  static const Map<String, String> categories = {
    // [OK] Hòa nhạc
    'hòa nhạc':
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',

    'triển lãm':
        'https://images.unsplash.com/photo-1518998053901-5348d3961a04?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',

    'sân khấu kịch':
        'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&w=800&q=80',

    'thể thao':
        'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=800&q=80',
  };

  // Map cho Cities
  static const Map<String, String> cities = {
    'hanoi':
        'https://plus.unsplash.com/premium_photo-1691960159059-04976913256a?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',

    'ho chi minh':
        'https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80',

    'da nang':
        'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=800&q=80',
  };

  static String getFallbackByTitle(String title) {
    final lowerTitle = title.toLowerCase();

    for (var entry in cities.entries) {
      if (lowerTitle.contains(entry.key)) return entry.value;
    }

    for (var entry in categories.entries) {
      if (lowerTitle.contains(entry.key)) return entry.value;
    }

    return "";
  }
}
