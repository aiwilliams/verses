import Foundation
import CoreData

let store = HeartversesStore()

var book = store.findBook("genesis", translation: "kjv")
store.addVerse(book, chapter: 1, number: 1, text: "In the beginning...")
