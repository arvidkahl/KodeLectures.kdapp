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

  {Editor,HelpView,TaskView,TaskOverview} = KodeLectures.Views
  
  constructor: ()->
    super
    @liveViewer = LiveViewer.getSingleton()
    @listenWindowResize()
    
    @autoScroll = yes
    @currentLecture = 0
    @lastSelectedCourse = 0
        
  delegateElements:->

    @splitViewWrapper = new KDView
    

    # OVERFLOW FIX
    overflowFix = ->
      height = ($ ".kdview.marKDown").height() - 39
      ($ ".kodepad-editors").height height
      
    ($ window).on "resize", overflowFix
    # window.ace = [@ace, @cssAce]
    # SHOULD REPLACE WITH LEGAL RESIZE LISTENER
    #do =>
      #lastAceHeight = 0
      #lastAceWidth = 0
      #setInterval =>
        #aceHeight = @aceView.getHeight()
        #aceWidth = @aceView.getWidth()
        #
        #if aceHeight isnt lastAceHeight or aceWidth isnt lastAceWidth
          #@ace.resize()
          #lastAceHeight = @aceView.getHeight()
          #lastAceWidth = @aceView.getWidth()
      #, 20
    
    @preview = new KDView
        cssClass: "preview-pane"
      
    @liveViewer.setPreviewView @preview
  

    @editor = new Editor
        defaultValue: Settings.lectures[@lastSelectedCourse].lectures[0].code
        callback: =>

    @editor.getView().hide()
      
    @taskView = new TaskView {},KodeLectures.Settings.lectures[@lastSelectedCourse or 0].lectures[0]
    @taskOverview = new TaskOverview {}, KodeLectures.Settings.lectures[@lastSelectedCourse or 0].lectures
      
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
        cssClass  : "kodepad-editors"
        type      : "vertical"
        resizable : yes
        sizes     : ["50%","50%"]
        views     : [@editorSplitView, @taskSplitView]

    @splitViewWrapper.addSubView @splitView
    
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
        @liveViewer.previewCode do @editor.getValue       
    
    @controlButtons.addSubView nextButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button next"
      title       : 'Next lecture'
      tooltip:
        title : 'Go to the next lecture'
      callback    : (event)=> @emit 'NextLectureRequested'
      
    @controlButtons.addSubView previousButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button previous"
      title       : 'Previous lecture'
      tooltip:
        title : 'Go to the previous lecture'
      callback    : (event)=> @emit 'PreviousLectureRequested'
    
    @on 'NextLectureRequested', =>
        unless @currentLecture is KodeLectures.Settings.lectures[@lastSelectedCourse or 0].lectures.length-1       
          previousButton.unsetClass 'disabled'
          @exampleCode.setValue ++@currentLecture 
          @exampleCode.getOptions().callback()
        else nextButton.setClass 'disabled'

    @on 'PreviousLectureRequested', =>
        unless @currentLecture is 0       
          nextButton.unsetClass 'disabled'
          @exampleCode.setValue --@currentLecture 
          @exampleCode.getOptions().callback()
        else previousButton.setClass 'disabled'


    @courseSelect = new KDSelectBox
      label: new KDLabelView
        title: 'Course: '
        
      defaultValue: @lastSelectedCourse or "0"
      cssClass: 'control-button code-examples'
      selectOptions: ({title: item.title, value: key} for item, key in KodeLectures.Settings.lectures)
      callback: =>
        @lastSelectedCourse = @courseSelect.getValue()
        @exampleCode.setSelectOptions ({title: item.title, value: key} for item, key in KodeLectures.Settings.lectures[@lastSelectedCourse or 0].lectures)
        @exampleCode.setValue 0
        @emit 'LectureChanged'

    @exampleCode = new KDSelectBox
      label: new KDLabelView
        title: 'Lecture: '
        
      defaultValue: @lastSelectedItem or "0"
      cssClass: 'control-button code-examples'
      selectOptions: ({title: item.title, value: key} for item, key in KodeLectures.Settings.lectures[@lastSelectedCourse or 0].lectures)
      callback: =>
        @emit 'LectureChanged'

    @on 'LectureChanged', =>
        #@lastSelectedCourse = @courseSelect.getValue()
        @lastSelectedItem = @exampleCode.getValue()        
        {code,language} = KodeLectures.Settings.lectures[@lastSelectedCourse].lectures[@lastSelectedItem]
        @ace.getSession().setValue code
        @taskView.emit 'LectureChanged',KodeLectures.Settings.lectures[@lastSelectedCourse].lectures[@lastSelectedItem]
       
        console.log 'emitting'
        @taskOverview.emit 'LectureChanged',{course:KodeLectures.Settings.lectures[@lastSelectedCourse],index:@lastSelectedItem}   
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
        
    @currentLang = KodeLectures.Settings.lectures[@lastSelectedCourse or 0].lectures[0].language
    
    #@controlView.addSubView codeButton
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
    
    @liveViewer.previewCode do @editor.getValue
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
        exec    : => 
          @editor.setValue @ace.getSession().getValue()
      
  viewAppended:->
    @delegateElements()
    @setTemplate do @pistachio
    @buildAce()