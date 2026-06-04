enum SmartQueueType {
  tonight,
  weekend,
  forgotten,
  continueReading,
  watchLater,
  learning,
  recentlySaved,
}

extension SmartQueueTypeLabel on SmartQueueType {
  String get label {
    return switch (this) {
      SmartQueueType.tonight => 'Tonight',
      SmartQueueType.weekend => 'Weekend',
      SmartQueueType.forgotten => 'Forgotten',
      SmartQueueType.continueReading => 'Continue Reading',
      SmartQueueType.watchLater => 'Watch Later',
      SmartQueueType.learning => 'Learning',
      SmartQueueType.recentlySaved => 'Recently Saved',
    };
  }
}
