enum StudiPassauState {
  notAuthenticated,
  loading,
  authenticating,
  authenticated,
  authenticationError,
  notFetched,
  fetching,
  fetched,
  fetchError,
  httpError,
}

extension StudiPassauStateExtension on StudiPassauState {
  bool get finished =>
      this == StudiPassauState.authenticationError ||
      this == StudiPassauState.authenticated ||
      this == StudiPassauState.fetched ||
      this == StudiPassauState.fetchError ||
      this == StudiPassauState.httpError;
}
