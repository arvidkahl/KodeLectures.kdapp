# > core.coffee
class KodeLectures.Core.Utils
  @notify = (message)=>
    @instance?.destroy()
    @instance = new KDNotificationView
      type : "mini"
      title: message

class KodeLectures.Core.LiveViewer

  {notify} = KodeLectures.Core.Utils

  @getSingleton: ()=> @instance ?= new @
  
  active: yes
  
  pistachios: /\{(\w*)?(\#\w*)?((?:\.\w*)*)(\[(?:\b\w*\b)(?:\=[\"|\']?.*[\"|\']?)\])*\{([^{}]*)\}\s*\}/g
  
  constructor: ()->
    @sessionId = KD.utils.uniqueId "kodepadSession"
  
  setPreviewView: (@previewView)->
    
  setSplitView: (@splitView)->
    
  setMainView: (@mainView)->
  
  previewCode: (code, options={})->
    return if not @active 
    
    unless not code or code is ''
    
      kiteController = KD.getSingleton "kiteController"
      
      command = switch @mainView.currentLang
     
        when 'javascript' then "echo '#{window.btoa code}' | base64 -d > temp.js; node temp.js;"
        when 'coffee'     then "echo '#{window.btoa code}' | base64 -d > temp.coffee; coffee temp.coffee -n;"
        when 'ruby'       then "echo '#{window.btoa code}' | base64 -d > temp.rb; ruby temp.rb;"
        when 'python'     then "echo '#{window.btoa code}' | base64 -d > temp.py; python temp.py;" 
                      
      kiteController.run command, (err, res)=>
      
        console.log err,res
        @mainView.taskView.emit 'ResultReceived',res unless err
        
        text = if err then "<div class='error'><pre>#{err.message}</pre></div>" else "<div class='success'><pre>#{res}</pre></div>"
      
        window.appView = @previewView
        try
          unless @mdPreview
            @previewView.addSubView @mdPreview = new KDView
              cssClass : 'has-markdown markdown-preview'
              partial : text
          else 
            @mdPreview.updatePartial text
          
        catch error
          notify error.message
        finally
          delete window.appView
  
  previewCSS: (code)->
    return if not @active
    session = "__kodepadCSS#{@sessionId}"

    if window[session]
      try
        window[session].remove()
        
    css = $ "<style scoped></style>"
    css.html code
    window[session] = css
    
    @previewView.domElement.prepend window[session]

class KodeLectures.Core.AppCreator
  
  {notify} = KodeLectures.Core.Utils
  
  @getSingleton: ()=> @instance ?= new @

  manifestTemplate: (appName)->
    
    {firstName, lastName, nickname} = KD.whoami().profile

    manifest: 
      """
      {
        "devMode": true,
        "version": "0.1",
        "name": "#{appName}",
        "identifier": "com.koding.#{nickname}.apps.#{appName.toLowerCase()}",
        "path": "~/Applications/#{appName}.kdapp",
        "homepage": "#{nickname}.koding.com/#{appName}",
        "author": "#{firstName} #{lastName}",
        "repository": "git://github.com/#{nickname}/#{appName}.kdapp.git",
        "description": "#{appName} : a Koding application created with the Kodepad.",
        "category": "web-app",
        "source": {
          "blocks": {
            "app": {
              "files": [
                "./index.coffee"
              ]
            }
          },
          "stylesheets": [
            "./resources/style.css"
          ]
        },
        "options": {
          "type": "tab"
        },
        "icns": {
          "128": "./resources/icon.128.png"
        }
      }
      """

  create: (name, coffee, css, callback) ->
    
    {manifest} = @manifestTemplate name
    
    {nickname} = KD.whoami().profile
    
    kite    = KD.getSingleton 'kiteController'
    finder  = KD.getSingleton "finderController"
    tree    = finder.treeController
    
    appPath      = "/Users/#{nickname}/Applications"
    basePath     = "#{appPath}/#{name}.kdapp"
    coffeeFile   = "#{basePath}/index.coffee"
    cssFile      = "#{basePath}/resources/style.css"
    manifestFile = "#{basePath}/.manifest"
    
    commands = [
      "mkdir -p #{basePath}"
      "mkdir -p #{basePath}/resources"
      "curl -kL https://koding.com/images/default.app.thumb.png -o #{basePath}/resources/icon.128.png"
    ]
    skeleton = commands.join ";"
    
    kite.run skeleton, (error, response)->
      return if error
      
      # Saving Coffee
      coffeeFileInstance = FSHelper.createFileFromPath coffeeFile
      coffeeFileInstance.save coffee
      
      # Saving CSS
      cssFileInstance = FSHelper.createFileFromPath cssFile
      cssFileInstance.save css
      
      # Saving Manifest
      manifestFileInstance = FSHelper.createFileFromPath manifestFile
      manifestFileInstance.save manifest
      
      KD.utils.wait 1000, -> 
        tree.refreshFolder tree.nodes[appPath]
        KD.getSingleton('kodingAppsController').refreshApps()
        do callback
    
    
  createGist: (coffee, css, callback) ->
    
    {nickname} = KD.whoami().profile
    
    gist = 
      description: """
      Kodepad Gist Share by #{nickname} on http://koding.com
      Author: http://#{nickname}.koding.com
      """
      public: yes
      files:
        "index.coffee": {content: coffee}
        "style.css": {content: css}

    kite    = KD.getSingleton 'kiteController'
    kite.run "mkdir -p /Users/#{nickname}/.kodepad", (err, res) ->
      
      tmpFile = "/Users/#{nickname}/.kodepad/.gist.tmp"
      
      tmp = FSHelper.createFileFromPath tmpFile
      tmp.save JSON.stringify(gist), (err, res)->
        return if err
        
        kite.run "curl -kL -A\"Koding\" -X POST https://api.github.com/gists --data @#{tmpFile}", (err, res)->
          callback err, JSON.parse(res)
          kite.run "rm -f #{tmpFile}"
          
class KodeLectures.Views.HelpView extends JView

    constructor:->
        super
        @text = new KDView
          partial : 'I am a help view'
        
        @on 'bold', =>
            @text.updatePartial 'Bold text uses ** text **'      
        @on 'italic', =>
            @text.updatePartial 'Italic text uses * text *'
    
    setDefault :->
        #@text.updatePartial 'Help.'

    pistachio:->
        """
        {{> @text }}
        """
class KodeLectures.Views.TaskView extends JView

  constructor:->
    super
    @setClass 'task-view'
  
    @taskTextView = new KDView
      cssClass : 'task-text-view has-markdown'
      partial : "<span class='data'>#{@getData().taskText}</span>"
  
    @resultView = new KDView
      cssClass : 'result-view hidden'
      
    @hintView = new KDView
      cssClass : 'hint-view has-markdown'
      partial : 'Show hint'
      click :=>
        @hintView.updatePartial "<span class='data'>#{marked @getData().codeHintText}</span>"
  
    @hintCodeView = new KDView
      cssClass : 'hint-code-view has-markdown'
      partial : 'Show solution'
      click :=>
        @hintCodeView.updatePartial "<span class='data'>#{marked "```\n"+@getData().codeHint+'\n```'}</span>"
      
    @on 'ResultReceived', (result)=>
      
      @resultView.show()
      
      if result.trim() is @getData().expectedResults
        @resultView.updatePartial @getData().submitSuccess
        @resultView.setClass 'success'
      else 
        @resultView.updatePartial @getData().submitFailure
        @resultView.unsetClass 'success'  
  
  pistachio:->
    """
    {{> @resultView }}
    {{> @taskTextView }}
    {{> @hintView}}
    {{> @hintCodeView}}
    

    """
    
  