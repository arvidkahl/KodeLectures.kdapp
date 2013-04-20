# > settings.coffee
# KD.enableLogs()

KodeLectures = 
  Settings:
    theme      : "ace/theme/monokai"
    exampleCode: null
    aceThrottle: 10
  Core:
    Utils      : null
    LiveViewer : null
  Views:
    Editor     : null
    MainView   : null
  Controllers:
    FileIOController : null


KodeLectures.Settings.lectures = []
#
#examples = [
  #{ 
    #"title":"Lecture 1: Console.log and Boolean values",
    #'embedType':'youtube',
    #'videoUrl':"http://www.youtube.com/embed/v2ifWcnQs6M",
    #"summary":"In this lecture, you will learn about Console and Booleans.",
    #"expectedResults":"true",
    #"submitSuccess":"Well done! You can procedd to the next part, where you will learn all about infinite loops.",
    #"submitFailure":"This is not the statement we are looking for.",
    #"language":"javascript",
    #"code":"// Hey there! enter your code here, please.\n\n// To log something to the console, you can use the properties of the console object\n// e.g. console.warn, console.error and so on...",
    #"codeHint":"\nThere are two Boolean values, `true` and `false`. The easiest way of logging a true value to the console is:\n\n```js\nconsole.log(true)\n```\n\nBut any truthy expression would do the trick, such as\n\n```js\nconsole.log(1==1)\n```\n\nor\n\n```js\nconsole.log(!(false && (1+2!==Infinity)))\n```\n\nBoth evaluate to `true` before being logged to the console.\n",
    #"codeHintText":"`Console.log()` prints to the console. Javascript knows only one truly true statement. That would be `true`.",
    #"taskText":"#Hello\n\nWelcome to the Lecture. Today we'll be learning about Boolean values. Named after [George Boole](http://en.wikipedia.org/wiki/George_Boole), these values are logical representations of Truth of Falsehood. Since there is nothing in between, only two mutually exclusive values exist in JavaScript, `true` and `false`.\n\nThere is also an  Object type called Boolean, which can take these values. It also supplies a few methods. But more on that later!\n\nTry printing a true statement to the console."
  #},
  #{ 
    #"title":"Lecture 2: While loops",
    #"summary":"This lecture is about loops",
    #"expectedResults":"1\n2\n3\n4\n5",
    #"submitSuccess":"Well done! You can procedd to the next part, where you will learn all more things.",
    #"submitFailure":"This is not the statement we are looking for.",
    #"language":"javascript",
    #"code":"// There are many ways to loop in JavaScript.\n//Try using while() in this assignment. We'll get to the other ones later.",
    #"codeHint":"\nOne way to use a while loop would be:\n\n```js\nvar i = 1;\nwhile(i<6){\n  console.log(i++);\n}\n```",
    #"codeHintText":"You might want to instantiate a variable, and increase its value one by one. And make sure to stop at some point. Maybe with a comparison?",
    #"taskText":"# What does it do?\n\nCreates a loop that executes a specified statement as long as the test condition evaluates to true. The condition is evaluated before executing the statement.\n\n##How do I use it?\n\n```js\nwhile (condition) {\n  statement\n}\n```\n\n- `condition`\n  - An expression evaluated before each pass through the loop. If this condition evaluates to true, statement is executed. When condition evaluates to false, execution continues with the statement after the while loop.\n- `statement`\n  - A statement that is executed as long as the condition evaluates to true. To execute multiple statements within the loop, use a block statement ({ ... }) to group those statements.\n\n##What you should do\nPrint the numbers `1` to `5` to the console, using a while loop."
    #
  #},
  #{
    #"title":"Lecture 3: A glimpse of CoffeeScript",
    #"summary":"Here comes CoffeeScript",
    #"expectedResults":"This is CoffeeScript",
    #"submitSuccess":"Well done! You can procedd to the next part, where you will learn all more things.",
    #"submitFailure":"This is not the statement we are looking for.",
    #"language":"coffee",
    #"code":"# Woah, what is this?\n# Well it's CoffeeScript, a language that compiles to JavaScript but is so much easier to write.\n\n# Don't believe me? Check this out:\n\n\nconsole.log name.toUpperCase() for name in ['Alice','Bob','Malice']",
    #"codeHint":"\n```js\nvar i = 1;\nwhile(i<6){\n  console.log(i++);\n}\n```",
    #"codeHintText":"Do something with console.log",
    #"taskText":"# CoffeeScript\n\n**CoffeeScript is a little language that compiles into JavaScript**. Underneath that awkward Java-esque patina, JavaScript has always had a gorgeous heart. CoffeeScript is an attempt to expose the good parts of JavaScript in a simple way.\n\n\nThe golden rule of CoffeeScript is: \"It's just JavaScript\". The code compiles one-to-one into the equivalent JS, and there is no interpretation at runtime. You can use any existing JavaScript library seamlessly from CoffeeScript (and vice-versa). The compiled output is readable and pretty-printed, passes through JavaScript Lint without warnings, will work in every JavaScript runtime, and tends to run as fast or faster than the equivalent handwritten JavaScript.\n\n\nLatest Version: 1.6.2"
  #}
#]
#
#cowExamples = [
  #{
    #"title":"A cow and how to tip it",
    #"summary":"Cow handling procedures",
    #"expectedResults":"Cow",
    #"submitSuccess":"Well done! You can procedd to the next part, where you will learn all more things.",
    #"submitFailure":"This is not the statement we are looking for.",
    #"language":"coffee",
    #"code":"cow",
    #"codeHint":"\n```js\nvar i = 1;\nwhile(i<6){\n  console.log(i++);\n}\n```",
    #"codeHintText":"Do something with the cow",
    #"taskText":"When fighting cows, take care.\n ![cow](http://1.media.collegehumor.cvcdn.com/50/64/4c98cc8cf252b327823784e870864ab6-cow-on-a-scooter.jpg)\nSeriously."
  #}
#]
#
#KodeLectures.Settings.lectures.push 
  #title : 'JavaScript 101'
  #description : 'This course will introduce JavaScript fundamentals. It will teach loops, logs and how to write small applications.'
  #lectures : []
  #
#KodeLectures.Settings.lectures[0].lectures.push example for example in examples
#
#KodeLectures.Settings.lectures.push 
  #title : 'How to ride a cow'
  #description : 'An instructive tutorial'
  #lectures : []
  #
#KodeLectures.Settings.lectures[1].lectures.push cowExamples[0]

  
