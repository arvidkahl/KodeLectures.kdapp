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
  
  active: no
  
  pistachios: /\{(\w*)?(\#\w*)?((?:\.\w*)*)(\[(?:\b\w*\b)(?:\=[\"|\']?.*[\"|\']?)\])*\{([^{}]*)\}\s*\}/g
  
  constructor: ()->
    @sessionId = KD.utils.uniqueId "kodepadSession"
  
  setPreviewView: (@previewView)->
     unless @mdPreview
        @previewView.addSubView @mdPreview = new KDView
          cssClass : 'has-markdown markdown-preview'
          partial : '<div class="info"><pre>When you run your code, you will see the results here</pre></div>'
    
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
      
        @mainView.taskView.emit 'ResultReceived',res unless err

        if res is '' then text = '<div class="info"><pre>KodeLectures received an empty response but no error.</pre></div>'
        else text = if err then "<div class='error'><pre>#{err.message}</pre></div>" else "<div class='success'><pre>#{res}</pre></div>"
      
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
  
    setDefault :->
  
    pistachio:->
        """
        """

class KodeLectures.Views.TaskView extends JView

  setMainView: (@mainView)->

  constructor:->
    super
    @setClass 'task-view'
  
    {videoUrl} = @getData()
    
    @embed = new KDView
      cssClass : 'embed'
      partial : if videoUrl
        """
        <iframe src="#{videoUrl}" frameborder="0" allowfullscreen></iframe>
        """
      else ''
      
    @embed.hide() unless videoUrl  
  
    @nextLectureButton = new KDButtonView
      title : 'Next Lecture'
      cssClass : 'cupid-green hidden fr task-next-button'
      callback :=>
        @mainView.emit 'NextLectureRequested'
  
    @taskTextView = new KDView
      cssClass : 'task-text-view has-markdown'
      partial : "<span class='text'>Assignment</span><span class='data'>#{marked @getData().taskText}</span>"
  
    @resultView = new KDView
      cssClass : 'result-view hidden'
      
    @hintView = new KDView
      cssClass : 'hint-view has-markdown'
      partial : '<span class="text">Show hint</span>'
      click :=>
        @hintView.updatePartial "<span class='text'>Hint</span><span class='data'>#{marked @getData().codeHintText}</span>"
  
    @hintCodeView = new KDView
      cssClass : 'hint-code-view has-markdown'
      partial : '<span class="text">Show solution</span>'
      click :=>
        @hintCodeView.updatePartial "<span class='text'>Solution</span><span class='data'>#{marked @getData().codeHint}</span>"
    
    @on 'LectureChanged',(lecture)=>
      @setData lecture
      @resultView.hide()
      @nextLectureButton.hide()
      @mainView.liveViewer.active = no
      @mainView.liveViewer.mdPreview?.updatePartial '<div class="info"><pre>When you run your code, you will see the results here</pre></div>'
      @taskTextView.updatePartial "<span class='text'>Assignment</span><span class='data'>#{marked @getData().taskText}</span>"
      @hintView.updatePartial '<span class="text">Show hint</span>'
      @hintCodeView.updatePartial '<span class="text">Show solution</span>'
      {videoUrl} = lecture
      if videoUrl
        @embed.show()
        @embed.updatePartial """<iframe src="#{videoUrl}" frameborder="0" allowfullscreen></iframe>"""
      else @embed.hide()
      @render()
    
    @on 'ResultReceived', (result)=>
      
      @resultView.show()
      
      if result.trim() is @getData().expectedResults
        @resultView.updatePartial @getData().submitSuccess
        @resultView.setClass 'success'
        @nextLectureButton.show()
      else 
        @resultView.updatePartial @getData().submitFailure
        @resultView.unsetClass 'success'  
  
  pistachio:->
    """
    {{> @nextLectureButton}}
    {{> @resultView }}    
    
    {{> @embed }}
    {{> @taskTextView }}
    
    {{> @hintView}}
    {{> @hintCodeView}}
    """
class KodeLectures.Views.TaskOverviewListItemView extends KDListItemView
    
  constructor:->
    super
    @setClass 'task-overview-item has-markdown'
    
    {title,summary} = @getData()
    
    @titleText = new KDView
      cssClass : 'title-text'
      partial : marked title
      
    @summaryText = new KDView
      partial : marked summary
    
  pistachio:->
    """
    <span class='data'>
    {{> @titleText}}
    </span>
    <div class='summary'>
      <span class='data'>
      {{> @summaryText}}
      </span>
    </div>
    """
  click:->
    @getDelegate().emit 'OverviewLectureClicked',@
    
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
    
class KodeLectures.Views.TaskOverview extends JView
  {TaskOverviewListItemView} = KodeLectures.Views
  constructor:->
    super
    @setClass 'task-overview'
    
    @lectureListController = new KDListViewController
      itemClass : TaskOverviewListItemView
      delegate : @
      #wrapper     : no
      #scrollView  : yes
      #keyNav      : yes
      #view        : new KDListView
        #keyNav    : yes
        #delegate  : @
        #cssClass  : "task-overview-item"
        #itemClass : TaskOverviewListItemView
    , items       : @getData()
 
    @lectureList = @lectureListController.getView()
    
    @lectureListController.listView.on 'OverviewLectureClicked', (item)=>
      @mainView.exampleCode.setValue @lectureListController.itemsOrdered.indexOf item 
      @mainView.emit 'LectureChanged',@lectureListController.itemsOrdered.indexOf item 
    
    @on 'LectureChanged', ({course,index})=>
      
      @lectureListController.removeAllItems()
      @lectureListController.instantiateListItems course.lectures
      
      item.unsetClass 'active' for item in @lectureListController.itemsOrdered 
      @lectureListController.itemsOrdered[index].setClass 'active'
  
  setMainView:(@mainView)->
    KD.utils.defer => @lectureListController.itemsOrdered[0].setClass 'active' 

  pistachio:->
    """
    {{> @lectureList}}
    """
    
    
class KodeLectures.Views.CourseSelectionItemView extends KDListItemView  
  
  constructor:->
    super
    @setClass 'selection-listitem'

    lectureCount = @getData().lectures.length
    
    @titleText = new KDView
      partial : "<span>#{@getData().title}</span><span class='lectures'>#{lectureCount} lecture#{if lectureCount is 1 then '' else 's'}</span>"
      cssClass : 'title'
      
    @descriptionText = new KDView
      partial : @getData().description
      cssClass : 'description'
  
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
  
  click:->
    @getDelegate().emit 'CourseSelected', @getData()
  
  pistachio:->
    """
    {{> @titleText}}
    {{> @descriptionText}}
    """
  
  
class KodeLectures.Views.CourseSelectionView extends JView
  {CourseSelectionItemView} = KodeLectures.Views
  
  constructor:->
    super
    courses = @getData()
    
    @courseController = new KDListViewController
      itemClass : CourseSelectionItemView
      delegate : @
    , items : courses
  
    @courseView = @courseController.getView()
    
    @courseController.listView.on 'CourseSelected', (course)=>
      @mainView.emit 'CourseChanged', courses.indexOf course

    @courseHeader = new KDView
      cssClass : 'course-header'
      partial : '<h1>Select a  course:</h1>'

  setMainView:(@mainView)->

  pistachio:->
    """
    {{> @courseHeader}}
    {{> @courseView}}
    """