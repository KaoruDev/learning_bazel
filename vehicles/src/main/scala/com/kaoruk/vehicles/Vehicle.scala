package com.kaoru.vehicles

trait Vehicle {
  val hasWheels: Boolean
  val make: String
  val model: String

  def accelerate(): Unit
}
