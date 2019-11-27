package com.kaoruk.vehicles

import com.kaoru.vehicles.Vehicle
import grizzled.slf4j.Logger

case class Car (override val make: String, override val model: String) extends Vehicle {
  private val logger = Logger(classOf[Car])

  override val hasWheels: Boolean = true

  override def accelerate(): Unit = {
    logger.info("VROOOOMMM!")
  }
}