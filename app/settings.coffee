# > settings.coffee
# KD.enableLogs()

KodeLectures = 
  Settings:
    theme      : "ace/theme/monokai"
    exampleCode: null
    exampleCSS : null
    aceThrottle: 400
  Core:
    Utils      : null
    LiveViewer : null
    AppCreator : null
  Views:
    Editor     : null
    MainView   : null


KodeLectures.Settings.lectures = []

###
# Sample Example
###
KodeLectures.Settings.lectures.push 
  title    : "Lecture 1: Console.log and Boolean values"
  expectedResults : 'true'
  submitSuccess : 'Well done! You can procedd to the next part, where you will learn all about infinite loops.'
  submitFailure : 'This is not the statement we are looking for.'
  language : 'javascript'
  code     : "// Hey there! enter your code here, please.\n\n// To log something to the console, you can use the properties of the console object\n// e.g. console.warn, console.error and so on..."
  codeHint : """

There are two Boolean values, `true` and `false`. The easiest way of logging a true value to the console is:

```js
console.log(true)
```

But any truthy expression would do the trick, such as

```js
console.log(1==1)
```

or

```js
console.log(!(false && (1+2!==Infinity)))
```

Both evaluate to `true` before being logged to the console.

"""
  codeHintText : '`Console.log()` prints to the console. Javascript knows only one truly true statement. That would be `true`.'
  taskText : """
 #Hello

Welcome to the Lecture. Today we'll be learning about Boolean values. Named after [George Boole](http://en.wikipedia.org/wiki/George_Boole), these values are logical representations of Truth of Falsehood. Since there is nothing in between, only two mutually exclusive values exist in JavaScript, `true` and `false`.

Try printing a true statement to the console."""
  
  
KodeLectures.Settings.lectures.push 
  title    : "Lecture 2: While loops"
  expectedResults : '1\n2\n3\n4\n5'
  submitSuccess : 'Well done! You can procedd to the next part, where you will learn all more things.'
  submitFailure : 'This is not the statement we are looking for.'
  language : 'javascript'
  code     : "// There are many ways to loop in JavaScript.\n//Try using while() in this assignment. We'll get to the other ones later."
  codeHint : """

```js
var i = 1;\nwhile(i<6){
  console.log(i++);
}
```
"""
  codeHintText : 'Do a flip!'
  taskText : """
# While loops

Print the numbers `1` to `5` to the console, using a while loop.
"""  
  
KodeLectures.Settings.lectures.push 
  title    : "Lecture 3: A glimpse of CoffeeScript"
  expectedResults : 'This is CoffeeScript'
  submitSuccess : 'Well done! You can procedd to the next part, where you will learn all more things.'
  submitFailure : 'This is not the statement we are looking for.'
  language : 'coffee'
  code     : """# Woah, what is this?\n# Well it's CoffeeScript, a language that compiles to JavaScript but is so much easier to write.\n\n# Don't believe me? Check this out:\n\n
  console.log name.toUpperCase() for name in ['Alice','Bob','Malice']
  """
  codeHint : """

```js
var i = 1;\nwhile(i<6){
  console.log(i++);
}
```
"""
  codeHintText : 'Do something with console.log'
  taskText : """
# CoffeeScript

**CoffeeScript is a little language that compiles into JavaScript**. Underneath that awkward Java-esque patina, JavaScript has always had a gorgeous heart. CoffeeScript is an attempt to expose the good parts of JavaScript in a simple way.


The golden rule of CoffeeScript is: "It's just JavaScript". The code compiles one-to-one into the equivalent JS, and there is no interpretation at runtime. You can use any existing JavaScript library seamlessly from CoffeeScript (and vice-versa). The compiled output is readable and pretty-printed, passes through JavaScript Lint without warnings, will work in every JavaScript runtime, and tends to run as fast or faster than the equivalent handwritten JavaScript.


Latest Version: 1.6.2
"""