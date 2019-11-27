namespace java com.kaoruk.vehicles.models

enum DateTimeProperty {
  millisecond, second, minute, hour, day, month, year
}

struct UserContext {
  1: optional string userid
  2: optional string systemid
  3: optional string role
}

exception VehicleError {
  1: string code
}

