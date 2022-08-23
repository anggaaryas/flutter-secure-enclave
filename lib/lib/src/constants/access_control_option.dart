enum AccessControlOption {
  devicePasscode("devicePasscode"),

  biometryAny("biometryAny"),

  biometryCurrentSet("biometryCurrentSet"),

  userPresence("userPresence"),

  watch("watch"),

  privateKeyUsage("privateKeyUsage"),

  applicationPassword("applicationPassword"),

  or("or"),

  and("and");

  final String des;

  const AccessControlOption(this.des);
}
