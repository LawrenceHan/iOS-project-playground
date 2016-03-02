//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
var movieRatings = ["Donnie Darko": 4, "Chungking Express": 5, "Dark City": 4]
print("I hae rated \(movieRatings.count) movies.")
let darkoRating = movieRatings["Donnie Darko"]
movieRatings["Dark City"] = 5
movieRatings
let oldRating: Int? = movieRatings.updateValue(5, forKey: "Donnie Darko")
if let lastRating = oldRating, currentRating = movieRatings["Donnie Darko"] {
    print("Old rating: \(lastRating); current rating: \(currentRating)")
}
movieRatings["The cabinet of Dr. Caligari"] = 5
//movieRatings.removeValueForKey("Dark City")
movieRatings["Dark City"] = nil
for (key, value) in movieRatings {
    print("The move \(key) was rated \(value)")
}
for movie in movieRatings.keys {
    print("User has rated \(movie)")
}
let watchedMovieds = Array(movieRatings.keys)