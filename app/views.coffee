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

class KodeLectures.Views.MainView extends JView

  {TaskView,TaskOverview,CourseSelectionView,SessionStatusView} = KodeLectures.Views
  
  constructor: ()->
    super
    @liveViewer = LiveViewer.getSingleton()
    @listenWindowResize()
    
    @autoScroll = yes
    @currentLecture = 0
    @currentFile = ''
    @lastSelectedCourse = 0
    @viewState = 'courses'
    
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
        @sessionStatus.emit 'FirebaseAttached'

    @courses = []
    
  delegateElements:->

    @splitViewWrapper = new KDView
  
    @preview = new KDView
        cssClass: "preview-pane"
      
    @liveViewer.setPreviewView @preview

    @editorContainer = new KDView
      domId : "firekode-container#{KD.utils.getRandomNumber()}"

    @codeMirrorEditor = CodeMirror @editorContainer.$()[0],
      lineNumbers : true
      mode        : "javascript"
      theme       : "monokai"

    @utils.wait 500, =>
        @firepad = Firepad.fromCodeMirror @ioController.firebaseRef, @codeMirrorEditor, userId: KD.whoami().profile.nickname
        
        @firepad.on "ready", =>
          #appView.getSubViews()[0].destroy() if @getOptions().sharedSession
          
          if @firepad.isHistoryEmpty()
            @firepad.setText """
              // JavaScript Editing with Firepad!
              function go() {
                var message = "Hello, world.";
                console.log(message);
              }
            """
      
    @taskView = new TaskView 
      delegate : @
    ,@courses[@lastSelectedCourse or 0]?.lectures?[0] or {}
   
    @taskOverview = new TaskOverview 
      delegate : @
    , @courses[@lastSelectedCourse or 0]?.lectures or []

    @editorSplitView = new KDSplitView
        type      : "horizontal"
        resizable : yes
        sizes     : ["62%","38%"]
        views     : [@editorContainer,@preview]    
    
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
        
        @ioController.saveFile @courses,@lastSelectedCourse,@lastSelectedItem, @currentFile, @codeMirrorEditor.getValue(), =>
          @liveViewer.previewCode @codeMirrorEditor.getValue(), @courses[@lastSelectedCourse].lectures[@lastSelectedItem].execute, 
            type: @courses[@lastSelectedCourse].lectures[@lastSelectedItem].previewType            
            previewPath: @courses[@lastSelectedCourse].lectures[@lastSelectedItem].previewPath
            coursePath: @courses[@lastSelectedCourse].path
    
    @controlButtons.addSubView @courseButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button next hidden"
      title       : 'Courses'
      tooltip:
        title : 'Go to the course list'
      callback    : (event)=> 
        @emit 'CourseRequested'
        @ioController.broadcastMessage {location:'courses'}
        
    @controlButtons.addSubView @lectureButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button previous"
      title       : 'Lecture'
      tooltip:
        title : 'Go to the current lecture'
      callback    : (event)=> 
        @emit 'LectureRequested' if @lastSelectedCourse
        @ioController.broadcastMessage {location:'lectures'}

     @languageSelect = new KDSelectBox
      label: new KDLabelView
        title: 'Language: '      
      selectOptions : [
        {title:'JavaScript',value:'javascript'}
        {title:'CoffeeScript',value:'coffeescript'}
        {title:'Shell',value:'shell'}
        {title:'PHP',value:'php'}
        {title:'Python',value:'python'}
        {title:'Ruby',value:'ruby'}
      ]
      title : 'Language Selection'
      defaultValue : 'JavaScript'
      cssClass: 'control-button language'
      callback:(item)=>
        @emit 'LanguageChanged', item
        @ioController.broadcastMessage {'language':item}
        
    @currentLang = @courses[@lastSelectedCourse or 0]?.lectures?[0]?.language or 'text'
    
    @sessionInput = new KDInputView
      label : new KDLabelView
        title : 'Session: '
      cssClass : 'session-input'
      callback :=>
        console.log 'Session input clicked'
        @ioController.attachFirebase @sessionInput.getValue(), =>
  
    
    @sessionJoinButton = new KDButtonView
      cssClass : 'editor-button clean-gray join-session-button'
      title : 'Join Session'
      callback :=>
        console.log 'Session Join Button clicked'
        @ioController.attachFirebase @sessionInput.getValue(), (sessionKey)=>
        
          console.log 'FIREBASE: Joined ',sessionKey

          new KDNotificationView
            title : 'You joined a KodeLecture session'
            content : 'Now, you will be able to collaborate with everyone else in this session.'
            duration : 5000

          @editorContainer.$().html ''
        
          @codeMirrorEditor = CodeMirror @editorContainer.$()[0],
            lineNumbers : true
            mode        : "javascript"
            theme       : "monokai"
        
          @firepad = Firepad.fromCodeMirror @ioController.firebaseRef, @codeMirrorEditor, userId: KD.whoami().profile.nickname
  
    @broadcastSwitch = new KDOnOffSwitch
      label : new KDLabelView
        title : "Broadcast: "
      size: "tiny"
      defaultValue : yes
      callback:(state)=>
        @ioController.allowBroadcast = state
        
    @sessionStatus = new SessionStatusView
      cssClass : 'session-status'
        
    @controlView.addSubView @languageSelect.options.label
    @controlView.addSubView @languageSelect
    
    #@controlView.addSubView @broadcastSwitch.options.label    
    #@controlView.addSubView @broadcastSwitch 
    
    @controlView.addSubView @sessionInput.options.label
    @controlView.addSubView @sessionInput
    @controlView.addSubView @sessionJoinButton
   
    @controlView.addSubView @sessionStatus
   
    @editorContainer.addSubView runButton 
    @controlView.addSubView @controlButtons
    
    @liveViewer.setSplitView @splitView
    @liveViewer.setMainView @
    
    @taskView.setMainView @
    @taskOverview.setMainView @
    @selectionView.setMainView @
   
    @attachListeners()
   
    @utils.wait 2000, =>
      @selectionView.setClass 'animate'
      @splitView.setClass 'animate'
    

  attachListeners :->
   
   @on 'LectureChanged', (lecture=0)=>   
      console.log '@LectureChanged',lecture
    
      
      @lastSelectedItem = lecture        
      {code,codeFile,language,files,previewType,expectedResults} = @courses[@lastSelectedCourse].lectures[@lastSelectedItem]
      
      @currentFile = if files?.length>0 then files[0] else 'tempfile'
      
      @ioController.readFile @courses, @lastSelectedCourse, @lastSelectedItem, @currentFile, (err,contents)=>
        unless err
          #@ace.getSession().setValue contents 
          @codeMirrorEditor.setValue contents 
        else 
          console.log 'Reading from lecture file failed with error: ',err
      
      @taskView.emit 'LectureChanged',@courses[@lastSelectedCourse].lectures[@lastSelectedItem]
      @taskOverview.emit 'LectureChanged',{course:@courses[@lastSelectedCourse],index:@lastSelectedItem}   
      
      @languageSelect.setValue language
      @emit 'LanguageChanged', language

      @ioController.broadcastMessage {location:'lectures',language}

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
        console.log '@CourseChanged',course
        @lastSelectedCourse = course
        @emit 'LectureRequested'
    
    @on 'CourseRequested', =>
        @viewState = 'courses'
        @splitView.setClass 'out'
        @selectionView.setClass 'in'
        @lectureButton.show()
        @courseButton.hide()
    
    @on 'LectureRequested',=>
        @viewState = 'lectures'
        @splitView.unsetClass 'out'
        @selectionView.unsetClass 'in'
        @courseButton.show()
        @lectureButton.hide()
   
    @on 'NextLectureRequested', =>
      if @lastSelectedItem isnt @courses[@lastSelectedCourse].lectures.length-1
        @emit 'LectureChanged',@lastSelectedItem+1 
        @ioController.broadcastMessage {lecture:@courses[@lastSelectedCourse].lectures[@lastSelectedItem+1],course:@courses[@lastSelectedCourse]}
    @on 'PreviousLectureRequested', =>
    
    @on 'LanguageChanged', (language) =>
      console.log 'Setting language to:',language
      @currentLang = language
      @codeMirrorEditor.setOption 'mode', language
    
    # iocontroller event bindings
    
    @ioController.on 'LanguageChanged', (language)=> @emit 'LanguageChanged', language
    @ioController.on 'LectureRequested', => @emit 'LectureRequested' unless @viewState is 'lectures'
    @ioController.on 'CourseRequested', => @emit 'CourseRequested' unless @viewState is 'courses'
    @ioController.on 'EditorContentChanged', ({text,origin})=> 
      
    @ioController.on 'CourseChanged', (course)=>
      log 'SYNC: Checking if this course is already active'
      unless course.title is @courses[@lastSelectedCourse]?.title 
        console.log 'SYNC: Oh, a remote course. Lets see if I already have this one'
        index = -1
        if @courses then index = i for course_,i in @courses when course_.title is course.title
        
        if index isnt -1 
          console.log 'Got it.'
          @lastSelectedCourse = index
          @utils.wait 0, => 
            @emit 'CourseChanged', @lastSelectedCourse
            @utils.wait 100, =>
              @emit 'LectureChanged', 0
          
        else
          console.log 'SYNC: Nope, adding it to my courses. Starting Import'
           
          importNotification = new KDNotificationView
            title     : 'Importing course used in this session'
            content   : 'Please wait until the course is saved to your app. This will only take a few seconds'
            duration  : 60000
          
          @ioController.importCourseFromRepository course.originUrl, course.originType, (importedCourse)=>
            @courses.push importedCourse
            
            importNotification.destroy()
          
            @lastSelectedCourse = @courses.length-1
            @utils.wait 0, => 
              @emit 'CourseChanged', @lastSelectedCourse
              @utils.wait 0, =>
                @emit 'LectureChanged', 0
      
      else 
        console.log 'SYNC: This is where I am already.'

    @ioController.on 'LectureChanged', (lecture)=>
      console.log 'SYNC: Checking if I already am at the lecture.'
      unless lecture.title is @courses?[@lastSelectedCourse]?.lectures?[@lastSelectedItem]?.title
        console.log 'SYNC: Nope, changing to the lecture'
        @utils.wait 0, => 
          index = 0
          if @courses[@lastSelectedCourse]? then index = i for lecture_,i in @courses[@lastSelectedCourse].lectures when lecture.title is lecture_.title
          @emit 'LectureChanged', index
      else 
        console.log 'SYNC: I am already there'
    
    @ioController.on 'UserJoined', (user)=>
      unless KD.whoami().profile.nickname is user
        if @ioController.isInstructor
          @sessionStatus.emit 'UserJoinedHost', user
          title = "#{user} joined your shared session."
          content = "All your changes will show up for every in your session as long as you have broadcasting enabled."
        else 
          @sessionStatus.emit 'UserJoined', user
          title = "#{user} joined this session"
          content = "Happy collaboration!"
        
        new KDNotificationView
          title : title 
          content : content
          duration : 5000
      else 
        @sessionStatus.emit 'UserJoinedSelf', @ioController.currentSessionKey
        
    @ioController.on 'UserLeft', (user)=>
      @sessionStatus.emit 'UserLeft', user
      
    @on "KDObjectWillBeDestroyed", =>
      @ioController.broadcastMessage {leave:KD.whoami().profile.nickname}
      #@firepad.dispose()
    

    # Resize hack for nested splitviews    
        
    @splitView.on 'ResizeDidStart', =>
      @resizeInterval = KD.utils.repeat 100, =>
        @taskSplitView._windowDidResize {}
        
    @splitView.on 'ResizeDidStop', =>
      KD.utils.killRepeat @resizeInterval
      @taskSplitView._windowDidResize {}

  pistachio: -> 
    """
    {{> @controlView}}
    {{> @splitViewWrapper}}
    """
#
  #buildAce: ->
    #ace = @getOptions().ace
    #try
      #
      #update = KD.utils.throttle =>
        #@editor.setValue @ace.getSession().getValue()
        #@editor.getView().domElement.trigger "keyup"
      #, Settings.aceThrottle
      #
      #@ace = ace.edit @aceView.domElement.get 0
      #@ace.setTheme Settings.theme
      #@ace.getSession().setMode "ace/mode/text"
      #@ace.getSession().setTabSize 2
      #@ace.getSession().setUseSoftTabs true
      #@ace.getSession().setValue @editor.getValue()
      #@ace.getSession().on "change", -> do update
  #
      #@editor.setValue @ace.getSession().getValue()
      #@ace.commands.addCommand
        #name    : 'save'
        #bindKey :
          #win   : 'Ctrl-S'
          #mac   : 'Command-S'
        #exec    : (event)=>
          #@editor.setValue @ace.getSession().getValue()
          #@ioController.saveFile @courses,@lastSelectedCourse,@lastSelectedItem, @currentFile, @ace.getSession().getValue()
      #
  viewAppended:->
    @delegateElements()
    @setTemplate do @pistachio
    #@buildAce()