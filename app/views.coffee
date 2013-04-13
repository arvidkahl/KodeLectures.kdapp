{Settings, Ace}   = KodeLectures
{LiveViewer, AppCreator, HelpView, TaskView} = KodeLectures.Core

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

  {Editor,HelpView,TaskView,TaskOverview,CourseSelectionView} = KodeLectures.Views
  
  constructor: ()->
    super
    @liveViewer = LiveViewer.getSingleton()
    @listenWindowResize()
    
    @autoScroll = yes
    @currentLecture = 0
    @lastSelectedCourse = 0
    
    @ioController = new KodeLectures.Controllers.FileIOController
    @ioController.emit 'CourseImportRequested'
    
    @ioController.on 'NewCourseImported', (course)=>
      console.log 'Forwarding new Course to view'
      @selectionView.emit 'NewCourseImported', course
      @courses.push course
    
    @courses = []
    
  delegateElements:->

    @splitViewWrapper = new KDView
    
    # OVERFLOW FIX
    overflowFix = ->
      height = ($ ".kdview.marKDown").height() - 39
      ($ ".kodepad-editors").height height
      
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
    #
    @preview = new KDView
        cssClass: "preview-pane"
      
    @liveViewer.setPreviewView @preview
  

    @editor = new Editor
        defaultValue: Settings.lectures[@lastSelectedCourse]?.lectures?[0]?.code or ''
        callback: =>

    @editor.getView().hide()
      
    @taskView = new TaskView {},@courses[@lastSelectedCourse or 0]?.lectures?[0] or {}
    @taskOverview = new TaskOverview {}, @courses[@lastSelectedCourse or 0]?.lectures or []
      
    @aceView = new KDView
        cssClass: 'editor code-editor'

    @aceWrapperView = new KDView
        cssClass : 'ace-wrapper-view'
    
    @aceWrapperView.addSubView @aceView

    @mdHelpView = new HelpView
        cssClass : 'md-help-view'

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
      sizes : ['62%','38%']
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
        
    runButton = new KDButtonView
      cssClass    : "cupid-green control-button run"
      title       : 'Run this code'
      tooltip:
        title : 'Run your code'
      callback    : (event)=>
        @liveViewer.active = yes
        @liveViewer.previewCode @editor.getValue(), @courses[@lastSelectedCourse].lectures[@lastSelectedItem].execute     
    
    @controlButtons.addSubView nextButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button next hidden"
      title       : 'Courses'
      tooltip:
        title : 'Go to the course list'
      callback    : (event)=> @emit 'CourseRequested'

        
    @controlButtons.addSubView previousButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button previous"
      title       : 'Lecture'
      tooltip:
        title : 'Go to the current lecture'
      callback    : (event)=> @emit 'LectureRequested'
      
    @on 'CourseRequested', =>
        @splitView.setClass 'out'
        @selectionView.setClass 'in'
        previousButton.show()
        nextButton.hide()
    
    @on 'LectureRequested',=>
        @splitView.unsetClass 'out'
        @selectionView.unsetClass 'in'
        nextButton.show()
        previousButton.hide()

    @on 'NextLectureRequested', =>
        unless @currentLecture is @courses[@lastSelectedCourse or 0]?.lectures?.length-1       
          @exampleCode.setValue ++@currentLecture 
          @exampleCode.getOptions().callback()
        
    @on 'PreviousLectureRequested', =>
        unless @currentLecture is 0       
          @exampleCode.setValue --@currentLecture 
          @exampleCode.getOptions().callback()
        

    @courseSelect = new KDSelectBox
      label: new KDLabelView
        title: 'Course: '
        
      defaultValue: @lastSelectedCourse or "0"
      cssClass: 'control-button code-examples'
      selectOptions: ({title: item.title, value: key} for item, key in @courses)
      callback: =>
        @emit 'CourseChanged',@courseSelect.getValue()
        
    @exampleCode = new KDSelectBox
      label: new KDLabelView
        title: 'Lecture: '
        
      defaultValue: @lastSelectedItem or "0"
      cssClass: 'control-button code-examples'
      selectOptions: ({title: item.title, value: key} for item, key in @courses[@lastSelectedCourse or 0]?.lectures or [])
      callback: =>
        @emit 'LectureChanged'
    
    @on 'CourseChanged', (course)=>
              
        if course          
          @courseSelect.setValue course
        
        @lastSelectedCourse = course
        @exampleCode._$select.find("option").remove() # replace with .removeSelectOptions()
        @exampleCode.setSelectOptions ({title: item.title, value: key} for item, key in @courses[@lastSelectedCourse or 0]?.lectures or [])
        @exampleCode.setValue 0
        @emit 'LectureChanged'
        @emit 'LectureRequested'
    
    @on 'LectureChanged', =>
        @lastSelectedItem = @exampleCode.getValue()        
        {code,codeFile,language} = @courses[@lastSelectedCourse].lectures[@lastSelectedItem]
        
        #@ace.getSession().setValue code
        
        @ioController.readFile @courses, @lastSelectedCourse, @lastSelectedItem, "codeFile", (err,contents)=>
          unless err
            console.log contents
            @ace.getSession().setValue contents 
          else 
            console.log err
        
        @taskView.emit 'LectureChanged',@courses[@lastSelectedCourse].lectures[@lastSelectedItem]
       
        console.log 'emitting'
        @taskOverview.emit 'LectureChanged',{course:@courses[@lastSelectedCourse],index:@lastSelectedItem}   
        @ace.getSession().setMode "ace/mode/#{language}"
        @currentLang = language
        @languageSelect.setValue language
        @currentLecture = @lastSelectedItem
    
    @languageSelect = new KDSelectBox
      label: new KDLabelView
        title: 'Language: '
        
      selectOptions : [
        {value:'javascript',title:'JavaScript'}
        {value:'coffee',title:'CoffeeScript'}
        {value:'ruby',title:'Ruby'}
        {value:'python',title:'Python'}
        ]
      title : 'Language Selection'
      defaultValue : 'javascript'
      cssClass: 'control-button language'
      callback:(item)=>
        @currentLang = item
        @ace.getSession().setMode "ace/mode/#{item}"
        
    @currentLang = @courses[@lastSelectedCourse or 0]?.lectures?[0]?.language or 'javascript'
    
    @controlView.addSubView @languageSelect.options.label
    @controlView.addSubView @languageSelect
    
    @controlView.addSubView @courseSelect.options.label
    @controlView.addSubView @courseSelect    
    
    @controlView.addSubView @exampleCode.options.label
    @controlView.addSubView @exampleCode
    @aceWrapperView.addSubView runButton 
    @controlView.addSubView @controlButtons
    
    @liveViewer.setSplitView @splitView
    @liveViewer.setMainView @
    
    @taskView.setMainView @
    @taskOverview.setMainView @
    @selectionView.setMainView @
   
    #@liveViewer.previewCode do @editor.getValue
    @utils.defer => ($ window).resize()
    @utils.wait 50, => 
        ($ window).resize()
        @ace?.resize()
    @utils.wait 1000, =>
    
      @ace.renderer.scrollBar.on 'scroll', =>
          if @autoScroll is yes
            @setPreviewScrollPercentage @getEditScrollPercentage()




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
      @ace.getSession().setMode "ace/mode/javascript"
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
          console.log event
          @editor.setValue @ace.getSession().getValue()
          @ioController.saveFile @courses,@lastSelectedCourse,@lastSelectedItem, @ace.getSession().getValue()
      
  viewAppended:->
    @delegateElements()
    @setTemplate do @pistachio
    @buildAce()