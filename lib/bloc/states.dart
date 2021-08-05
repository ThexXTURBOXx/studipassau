enum StudiPassauState {
  NOT_AUTHENTICATED,
  LOADING,
  AUTHENTICATING,
  AUTHENTICATED,
  AUTHENTICATION_ERROR,
  NOT_FETCHED,
  FETCHING,
  FETCHED,
  FETCH_ERROR,
  HTTP_ERROR,
}

extension StudiPassauStateExtension on StudiPassauState {
  bool get finished =>
      this == StudiPassauState.AUTHENTICATION_ERROR ||
      this == StudiPassauState.AUTHENTICATED ||
      this == StudiPassauState.FETCHED ||
      this == StudiPassauState.FETCH_ERROR ||
      this == StudiPassauState.HTTP_ERROR;
}
