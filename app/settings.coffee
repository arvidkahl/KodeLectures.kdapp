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


KodeLectures.Settings.exampleCodes = []

###
# Sample Example
###
KodeLectures.Settings.exampleCodes.push 
  title    : "Test"
  expectedResults : 'true'
  submitSuccess : 'Well done!'
  submitFailure : 'This is not the statement we are looking for.'
  code     : ''
  codeHint : "console.log(true)"
  codeHintText : '`Console.log()` prints to the console. Javascript knows only one truly true statement. That would be `true`.'
  taskText : 'Print a true statement to the console.'
  
  
KodeLectures.Settings.exampleCodes.push 
  title: "JavaScript Sample"
  code: 
    """
// This is a sample JavaScript code snippet
// It's running on the Node.js platform

console.log("Nodejs!");
console.log("Version: " + process.version);

// Let's do some basic math:

var a = 1, b = 2;

console.log(a + b === 3);
  """

KodeLectures.Settings.exampleCodes.push 
  title: "CoffeeScript Sample"
  code: 
    """
console.log word for word in ['Hello', 'World']
"""
