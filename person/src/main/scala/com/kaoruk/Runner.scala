package com.kaoruk

import scala.util.{Failure, Try}

import com.kaoruk.pets.Cat
import com.kaoruk.vehicles.Car
import grizzled.slf4j.Logger

import java.lang.Runnable
import java.util.concurrent.TimeoutException
import java.util.concurrent.atomic.AtomicBoolean

object Runner extends App {
  val logger = Logger("com.kaoruk.Runner")
  val running = new AtomicBoolean(true)

  val myCar = Car("Nissan", "370z")
  val cat = Cat("Frank")

  val t = new Thread(() => {
    while (running.get()) {
      myCar.accelerate()
      logger.info(s"My car, ${myCar.make} ${myCar.model} has wheels: ${myCar.hasWheels}")
      logger.info(s"My cat ${cat.name} says ${cat.speak}")
      Thread.sleep(1000)
    }
  })

  t.start()

  sys.addShutdownHook(() => {
    logger.info("Shutting down...")
    running.set(false)
    Thread.sleep(1500)
    if (t.isAlive) {
      logger.info("Thread did not shutdown after 1.5 seconds, interrupting...")
      t.interrupt()
    }
  })

  t.join()
}
