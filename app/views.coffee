{Settings, Ace}   = KodeLectures
{LiveViewer, TaskView} = KodeLectures.Core

require ["https://raw.github.com/chjj/marked/master/lib/marked.js"], (marked)=>
        options = {}
      
        options.gfm         ?= yes
        options.sanitize    ?= yes
        options.highlight   ?= (code, lang)->
            try
                hljs.highlight(lang, code).value
            catch e
                try
                    hljs.highlightAuto(code).value
                catch _e
                    code
        options.breaks      ?= yes
        options.langPrefix  ?= 'lang-'

        marked.setOptions options

class KodeLectures.Views.Editor
  constructor: (options)->
    
    @view = new KDView
      tagName: "textarea"
    
    @view.domElement.css
      "font-family": "monospace"
    
    @setValue options.defaultValue if options.defaultValue
    @view.domElement.keyup options.callback if options.callback
    
  setValue: (value)-> @view.domElement.html value
  
  getValue: -> @view.domElement.val()
  
  getView: -> @view
  
  getElement: -> @view.domElement.get 0

class KodeLectures.Views.MainView extends JView

  {Editor,TaskView,TaskOverview,CourseSelectionView} = KodeLectures.Views
  
  constructor: ()->
    super
    @liveViewer = LiveViewer.getSingleton()
    @listenWindowResize()
    
    @autoScroll = yes
    @currentLecture = 0
    @currentFile = ''
    @lastSelectedCourse = 0
    
    @ioController = new KodeLectures.Controllers.FileIOController
    @ioController.emit 'CourseImportRequested'
    
    @ioController.on 'NewCourseImported', (course)=>
      #console.log 'Forwarding new Course to view'
      @selectionView.emit 'NewCourseImported', course
      @courses.push course
    
    @ioController.on 'CourseFilesReset', (course)=>
      # make sure the lecture gets reloaded 
      @emit 'LectureChanged', @lastSelectedItem

    @ioController.attachFirebase null, (sessionKey,state)=>
      if state is 'fresh'
        console.log 'Firebase successfully attached and instantiated.'
        @sessionInput.setValue sessionKey

    @courses = []
    
  delegateElements:->

    @splitViewWrapper = new KDView
    
    # OVERFLOW FIX
    overflowFix = ->
      height = ($ ".kdview.kodelectures").height() - 39
      ($ ".kodepad-editors").height height
      #
    ($ window).on "resize", overflowFix
    # window.ace = [@ace, @cssAce]
    # SHOULD REPLACE WITH LEGAL RESIZE LISTENER
    do =>
      lastAceHeight = 0
      lastAceWidth = 0
      setInterval =>
        aceHeight = @aceView.getHeight()
        aceWidth = @aceView.getWidth()
        
        if aceHeight isnt lastAceHeight or aceWidth isnt lastAceWidth
          @ace.resize()
          lastAceHeight = @aceView.getHeight()
          lastAceWidth = @aceView.getWidth()
      , 20
    
    @preview = new KDView
        cssClass: "preview-pane"
      
    @liveViewer.setPreviewView @preview
  
    @editor = new Editor
        defaultValue: ''
        callback: =>

    @editor.getView().hide()
      
    @taskView = new TaskView {},@courses[@lastSelectedCourse or 0]?.lectures?[0] or {}
    @taskOverview = new TaskOverview {}, @courses[@lastSelectedCourse or 0]?.lectures or []
      
    @aceView = new KDView
        cssClass: 'editor code-editor'

    @aceWrapperView = new KDView
        cssClass : 'ace-wrapper-view'
    
    @aceWrapperView.addSubView @aceView

    @editorSplitView = new KDSplitView
        type      : "horizontal"
        resizable : yes
        sizes     : ["62%","38%"]
        views     : [@aceWrapperView,@preview]    
    
    @taskSplitViewWrapper = new KDView
    
    @taskSplitView = new KDSplitView
      type : 'vertical'
      resizable : no
      cssClass  : 'task-splitview'
      sizes : [null,'200px']
      views : [@taskView,@taskOverview]
      
    @splitView = new KDSplitView
        cssClass  : "kodepad-editors out"
        type      : "vertical"
        resizable : yes
        sizes     : ["50%","50%"]
        views     : [@editorSplitView, @taskSplitView]

    @splitViewWrapper.addSubView @splitView
    
    @splitViewWrapper.addSubView @selectionView = new CourseSelectionView
      cssClass : 'selection-view in'
    ,Settings.lectures
    
    @buildAce()
    
    @splitView.on 'ResizeDidStop', =>
        @ace?.resize()

    @controlButtons = new KDView
      cssClass    : 'header-buttons'

    @controlView = new KDView
      cssClass: 'control-pane editor-header'  
    
    @controlButtons.addSubView @importButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button import"
      title       : 'Import Course'
      callback : =>
        modal = new KDModalViewWithForms
          title                   : "Import a Course"
          content                 : ""
          overlay                 : yes
          cssClass                : "new-kdmodal"
          width                   : 500
          height                  : "auto"
          tabs                    : 
            navigable             : yes 
            goToNextFormOnSubmit  : no              
            forms                 :
              "Import From Repository"  :
                  fields          :                      
                    "Repo URL"    :
                      label       : 'Repo URL'
                      itemClass   : KDInputView
                      name        : 'url'
                  buttons         :  
                    'Import'      :
                      title       : 'Import'
                      type        : 'submit'
                      style       : 'modal-clean-green'
                      loader      :
                        color     : "#ffffff"
                        diameter  : 12
                      callback    : =>
                        @ioController.importCourseFromRepository modal.modalTabs.forms['Import From Repository'].inputs['Repo URL'].getValue(), 'git',=>
                          console.log 'Done importing from repository. Closing modal.'
                          modal.destroy()
                    Cancel        :
                      title       : 'Cancel'
                      type        : 'modal-cancel'
                      callback    : =>
                        modal.destroy()
              
              "Import From URL"   :
                  buttons         :
                    'Import'      :
                      title       : 'Import'
                      type        : 'submit'
                      style       : 'modal-clean-green'
                      loader      :
                        color     : "#ffffff"
                        diameter  : 12    
                      callback    : =>
                        @ioController.importCourseFromURL modal.modalTabs.forms['Import From URL'].inputs['URL'].getValue(), =>
                          console.log 'Done importing from url. Closing modal.'
                          modal.destroy()
                    Cancel        :
                      title       : 'Cancel'
                      type        : 'modal-cancel'
                      callback    : =>
                        modal.destroy()
                  fields          :
                    "Notice"      :
                      itemClass   : KDCustomHTMLView
                      tagName     : 'span'
                      partial     : '<strong>Warning</strong>. This feature is experimental. Due to the nature of HTTP requests, the files requested might not yield their source code but get executed by the webserver. Consider hosting your lecture on GitHub.'
                      cssClass    : 'modal-warning'  
      
                    "URL"         :
                      label       : 'URL'
                      itemClass   : KDInputView 
                      name        : 'url'
      
    runButton = new KDButtonView
      cssClass    : "cupid-green control-button run"
      title       : 'Save and Run your code'
      tooltip:
        title : 'Save and Run your code'
      callback    : (event)=>
        @liveViewer.active = yes
        
        @ioController.saveFile @courses,@lastSelectedCourse,@lastSelectedItem, @currentFile, @ace.getSession().getValue(), =>
          @liveViewer.previewCode @editor.getValue(), @courses[@lastSelectedCourse].lectures[@lastSelectedItem].execute, 
            type: @courses[@lastSelectedCourse].lectures[@lastSelectedItem].previewType            
            previewPath: @courses[@lastSelectedCourse].lectures[@lastSelectedItem].previewPath
            coursePath: @courses[@lastSelectedCourse].path
    
    @controlButtons.addSubView @courseButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button next hidden"
      title       : 'Courses'
      tooltip:
        title : 'Go to the course list'
      callback    : (event)=> @emit 'CourseRequested'

        
    @controlButtons.addSubView @lectureButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button previous"
      title       : 'Lecture'
      tooltip:
        title : 'Go to the current lecture'
      callback    : (event)=> @emit 'LectureRequested' if @lastSelectedCourse

     @languageSelect = new KDSelectBox
      label: new KDLabelView
        title: 'Language: '      
      selectOptions : __aceSettings.getSyntaxOptions()
      title : 'Language Selection'
      defaultValue : 'text'
      cssClass: 'control-button language'
      callback:(item)=>
        console.log "ace/mode/#{item}"
        @currentLang = item
        @ace.getSession().setMode "ace/mode/#{item}"
        
    @currentLang = @courses[@lastSelectedCourse or 0]?.lectures?[0]?.language or 'text'
    
    @sessionInput = new KDInputView
      label : new KDLabelView
        title : 'Session: '
      cssClass : 'session-input'
      callback :=>
        console.log 'Session input clicked'
        @ioController.attachFirebase @sessionInput.getValue()
    
    @sessionJoinButton = new KDButtonView
      cssClass : 'editor-button clean-gray join-session-button'
      title : 'Join Session'
      callback :=>
        console.log 'Session Join Button clicked'
        @ioController.attachFirebase @sessionInput.getValue(), (sessionKey)=>
          console.log 'Joined ',sessionKey
    
    @controlView.addSubView @languageSelect.options.label
    @controlView.addSubView @languageSelect
    @controlView.addSubView @sessionInput.options.label
    @controlView.addSubView @sessionInput
    @controlView.addSubView @sessionJoinButton
   
    @aceWrapperView.addSubView runButton 
    @controlView.addSubView @controlButtons
    
    @liveViewer.setSplitView @splitView
    @liveViewer.setMainView @
    
    @taskView.setMainView @
    @taskOverview.setMainView @
    @selectionView.setMainView @
   
    @attachListeners()
   
    @utils.defer => 
      ($ window).resize()

    @utils.wait 50, => 
      ($ window).resize()
      @ace?.resize()

    @utils.wait 1000, =>
      @ace.renderer.scrollBar.on 'scroll', =>
        if @autoScroll is yes
          @setPreviewScrollPercentage @getEditScrollPercentage()
    
    @utils.wait 2000, =>
      @selectionView.setClass 'animate'
      @splitView.setClass 'animate'
    

  attachListeners :->
   
   @on 'LectureChanged', (lecture=0)=>   
      @lastSelectedItem = lecture        
      {code,codeFile,language,files,previewType,expectedResults} = @courses[@lastSelectedCourse].lectures[@lastSelectedItem]
      
      @currentFile = if files?.length>0 then files[0] else 'tempfile'
      
      @ioController.readFile @courses, @lastSelectedCourse, @lastSelectedItem, @currentFile, (err,contents)=>
        unless err
          @ace.getSession().setValue contents 
        else 
          console.log 'Reading from lecture file failed with error: ',err
      
      @taskView.emit 'LectureChanged',@courses[@lastSelectedCourse].lectures[@lastSelectedItem]
      @taskOverview.emit 'LectureChanged',{course:@courses[@lastSelectedCourse],index:@lastSelectedItem}   
      
      console.log 'setting mode to',"ace/mode/#{language}"
      @ace.getSession().setMode "ace/mode/#{language}"
      @currentLang = language
      @languageSelect.setValue language
      @currentLecture = @lastSelectedItem
            
      if expectedResults is null and @lastSelectedItem isnt @courses[@lastSelectedCourse].lectures.length-1
        @taskView.emit 'ReadyForNextLecture'
      else 
        @taskView.emit 'HideNextLectureButton'
    
      if previewType is 'terminal' 
        @liveViewer.active = yes
        @liveViewer.previewCode "", @courses[@lastSelectedCourse].lectures[@lastSelectedItem].execute, 
          type:previewType
          coursePath:@courses[@lastSelectedCourse].path
      else 
        @liveViewer.mdPreview?.show()
        @liveViewer.terminal?.hide()

    @on 'CourseChanged', (course)=>              
        @lastSelectedCourse = course
        @emit 'LectureRequested'
    
    @on 'CourseRequested', =>
        @splitView.setClass 'out'
        @selectionView.setClass 'in'
        @lectureButton.show()
        @courseButton.hide()
    
    @on 'LectureRequested',=>
        @splitView.unsetClass 'out'
        @selectionView.unsetClass 'in'
        @courseButton.show()
        @lectureButton.hide()
   
    @on 'NextLectureRequested', =>
      @emit 'LectureChanged',@lastSelectedItem+1 if @lastSelectedItem isnt @courses[@lastSelectedCourse].lectures.length-1
    @on 'PreviousLectureRequested', =>
        
    # Resize hack for nested splitviews    
        
    @splitView.on 'ResizeDidStart', =>
      @resizeInterval = KD.utils.repeat 100, =>
        @taskSplitView._windowDidResize {}
        
    @splitView.on 'ResizeDidStop', =>
      KD.utils.killRepeat @resizeInterval
      @taskSplitView._windowDidResize {}

  getEditScrollPercentage:->

  setPreviewScrollPercentage:(percentage)->
  
  pistachio: -> 
    """
    {{> @controlView}}
    {{> @editor.getView()}}
    {{> @splitViewWrapper}}
    """
  buildAce: ->
    ace = @getOptions().ace
    try
      
      update = KD.utils.throttle =>
        @editor.setValue @ace.getSession().getValue()
        @editor.getView().domElement.trigger "keyup"
      , Settings.aceThrottle
      
      @ace = ace.edit @aceView.domElement.get 0
      @ace.setTheme Settings.theme
      @ace.getSession().setMode "ace/mode/text"
      @ace.getSession().setTabSize 2
      @ace.getSession().setUseSoftTabs true
      @ace.getSession().setValue @editor.getValue()
      @ace.getSession().on "change", -> do update
  
      @editor.setValue @ace.getSession().getValue()
      @ace.commands.addCommand
        name    : 'save'
        bindKey :
          win   : 'Ctrl-S'
          mac   : 'Command-S'
        exec    : (event)=>
          #console.log event
          @editor.setValue @ace.getSession().getValue()
          @ioController.saveFile @courses,@lastSelectedCourse,@lastSelectedItem, @currentFile, @ace.getSession().getValue()
      
  viewAppended:->
    @delegateElements()
    @setTemplate do @pistachio
    #@buildAce()