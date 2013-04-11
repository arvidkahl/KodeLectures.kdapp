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
  title    : "Console.log and Boolean values"
  expectedResults : 'true'
  submitSuccess : 'Well done! You can procedd to the next part, where you will learn all about infinite loops.'
  submitFailure : 'This is not the statement we are looking for.'
  language : 'javascript'
  code     : ""
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
  title    : "While loops"
  expectedResults : '1\n2\n3\n4\n5'
  submitSuccess : 'Well done! You can procedd to the next part, where you will learn all more things.'
  submitFailure : 'This is not the statement we are looking for.'
  language : 'javascript'
  code     : ""
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