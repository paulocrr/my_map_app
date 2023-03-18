enum ScreenState {
  idle,
  loading,
  error,
  completed;

  bool isLoading() {
    return this == ScreenState.loading;
  }

  bool isError() {
    return this == ScreenState.error;
  }

  bool isCompleted() {
    return this == ScreenState.completed;
  }
}
