class ManagerCacheOption {
  final Duration cacheTime;
  final bool useCache;

  const ManagerCacheOption({
    required this.cacheTime,
    this.useCache = true,
  });

  const ManagerCacheOption.non()
      : useCache = false,
        cacheTime = Duration.zero;
}
