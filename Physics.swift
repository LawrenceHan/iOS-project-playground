//: Playground - noun: a place where people can play

import Cocoa

struct Vector: CustomStringConvertible {
    var x: Double
    var y: Double
    
    init() {
        self.init(x: 0, y: 0)
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    func vectorByAddingVector(vector : Vector) -> Vector {
        return Vector(x: x + vector.x, y: y + vector.y)
    }
    
    var length: Double {
        return sqrt(x*x + y*y)
    }
    
    var description: String {
        return "(\(x), \(y))"
    }
}

let gravity = Vector(x: 0.0, y: -9.8)

func +(left: Vector, right: Vector) -> Vector {
    return left.vectorByAddingVector(right)
}

func *(left: Vector, right: Double) -> Vector {
    return Vector(x: left.x * right, y: left.y * right)
}

let twoGs = gravity + gravity
let twoGsAlso = gravity * 2.0

func *(left: Double, right: Vector) -> Vector {
    return right * left
}

class Particle {
    var position: Vector
    var velocity: Vector
    var acceleration: Vector
    
    init(position: Vector) {
        self.position = position
        self.velocity = Vector()
        self.acceleration = Vector()
    }
    
    convenience init() {
        self.init(position: Vector())
    }
    
    func tick(dt: NSTimeInterval) {
        velocity = velocity + acceleration * dt
        position = position + velocity * dt
        position.y = max(0, position.y)
    }
}

class Simulation {
    var particles: [Particle] = []
    var time: NSTimeInterval = 0.0
    
    func addParticle(particle: Particle) {
        particles.append(particle)
    }
    
    func tick(dt: NSTimeInterval) {
        for particle in particles {
            particle.acceleration = particle.acceleration + gravity
            particle.tick(dt)
            particle.acceleration = Vector()
            particle.position.y
        }
        time += dt
        particles = particles.filter { particle in
            let live = particle.position.y > 0.0
            if !live {
                print("Particle terminated at time \(self.time)")
            }
            return live
        }
    }
}

let simuation = Simulation()

class Rocket: Particle {
    let thrust: Double
    var thrustTimeRemaining: NSTimeInterval
    let direction = Vector(x: 0, y: 1)
    
    convenience init(thrust: Double, thrustTime: NSTimeInterval) {
        self.init(position: Vector(), thrust: thrust, thrustTime: thrustTime)
    }
    
    init(position: Vector, thrust: Double, thrustTime: NSTimeInterval) {
        self.thrust = thrust
        self.thrustTimeRemaining = thrustTime
        super.init(position: position)
    }
    
    override func tick(dt: NSTimeInterval) {
        if thrustTimeRemaining > 0.0 {
            thrustTimeRemaining
            let thrustTime = min(dt, thrustTimeRemaining)
            let thrustToApply = thrust * thrustTime
            let thrustForce = direction * thrustToApply
            acceleration = acceleration + thrustForce
            thrustTimeRemaining -= thrustTime
        }
        
        acceleration.y
        velocity.y
        if (acceleration.y < 0.0) {
            
        }
        
        super.tick(dt)
    }
}

//let ball = Particle()
//ball.acceleration = Vector(x: 0, y: 100)
//simuation.addParticle(ball)

let rocket = Rocket(thrust: 10.0, thrustTime: 60)
simuation.addParticle(rocket)

while simuation.particles.count > 0 && simuation.time < 500 {
    simuation.tick(1.0)
}

print("Gravity is \(gravity)")


