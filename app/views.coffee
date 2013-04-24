{Settings, Ace}   = KodeLectures
{LiveViewer, TaskView} = KodeLectures.Core

# If we want to throw some mad keyboard event magic around, this will help

#require ["https://raw.github.com/termi/DOM-Keyboard-Event-Level-3-polyfill/0.4/DOMEventsLevel3.shim.js"], (domPolyfill)=>
  #console.log 'Polyfill loaded.'

# Think of maybe using MarkdownDoc on the remote..

require ["https://raw.github.com/chjj/marked/master/lib/marked.js"], (marked)=>
  console.log 'Markdown parser loaded.'
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

  {TaskView,TaskOverview,CourseSelectionView,SessionStatusView,ChatView} = KodeLectures.Views
  
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
        #@sessionInput.setValue sessionKey
        @sessionStatus.emit 'FirebaseAttached'

    @courses = []
    
  save:->
    console.log 'Saving editor contents to file.'
    @ioController.saveFile @courses,@lastSelectedCourse,@lastSelectedItem, @currentFile, @codeMirrorEditor.getValue()  
  
  buildCodeMirror:->
    @codeMirrorEditor = CodeMirror @editorContainer.$()[0],
      lineNumbers : true
      mode        : "javascript"
      tabSize                    : options.tabSize            or 2
      lineNumbers                : options.lineNumbers        or yes
      #autofocus                  : options.autofocus          or yes
      theme                      : options.theme              or "monokai"
      value                      : options.value              or ""
      styleActiveLine            : options.highlightLine      or yes
      highlightSelectionMatches  : options.highlightSelection or yes
      matchBrackets              : options.matchBrackets      or yes
      autoCloseBrackets          : options.closeBrackets      or yes
      autoCloseTags              : options.closeTags          or yes
      extraKeys                  : 
        "Cmd-S"                  : => @save()
        "Ctrl-S"                 : => @save()
        "Shift-Alt-R"            : => 
          @save()
          @runButton.options.callback()
  
  delegateElements:->

    @splitViewWrapper = new KDView
  
    @preview = new KDView
        cssClass: "preview-pane"
        
    @previewButtons = new KDView
      cssClass : 'preview-buttons'      
    
    @liveViewer.setPreviewView @preview

    @editorContainer = new KDView
      domId : "firekode-container#{KD.utils.getRandomNumber()}"

    @buildCodeMirror()

    @utils.wait 10, =>
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
        sizes     : ["62%", "30px",null]
        views     : [@editorContainer,@previewButtons,@preview]    
    
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
      
    @runButton = new KDButtonView
      cssClass    : "cupid-green control-button run"
      title       : 'Save and Run your code (Shift-Alt-R)'
      tooltip:
        title : 'Save and Run your code (Shift-Alt-R)'
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
    
    #@sessionInput = new KDInputView
      #label : new KDLabelView
        #title : 'Session: '
      #cssClass : 'session-input'
      #callback :=>
        #console.log 'Session input clicked'
        #@ioController.attachFirebase @sessionInput.getValue(), =>
  
    @sessionShareButton = new KDButtonView
      cssClass : 'editor-button clean-gray join-session-button'
      title : 'Create Session'
      callback : =>
        @sessionStatus.show()
        @sessionShareButton.setTitle 'Share Session'
        modal = new KDModalViewWithForms
          title                   : "Share this session"
          content                 : ""
          overlay                 : yes
          cssClass                : "new-kdmodal"
          width                   : 500
          height                  : "auto"
          tabs                    : 
            navigable             : yes 
            goToNextFormOnSubmit  : no              
            forms                 :
              "Share Session"  :
                  fields          :                      
                    "Notice"      :
                      itemClass   : KDCustomHTMLView
                      tagName     : 'span'
                      partial     : 'You can share this session to collaborate with as many people as you like. Just pass them the following key and they can join your session!'
                      cssClass    : 'modal-info'  
                    "Your Session ID"    :
                      label       : 'Your Session ID'
                      itemClass   : KDInputView
                      disabled    : yes
                      cssClass    : 'session-id-input'
                      name        : 'sessionKey'
                      defaultValue: @ioController.currentSessionKey
                  buttons         :  
                    'Okay, thanks!'      :
                      title       : 'Okay, thanks!'
                      style       : 'modal-clean-green'
                      loader      :
                        color     : "#ffffff"
                        diameter  : 12
                      callback    : =>
                        modal.destroy()
              "What is this?"   :
                  buttons         :
                    'Alright!'      :
                      title       : 'Alright!'
                      #type        : 'submit'
                      style       : 'modal-clean-green'
                      loader      :
                        color     : "#ffffff"
                        diameter  : 12    
                      callback    : =>
                        modal.destroy()
                  fields          :
                    "Notice"      :
                      itemClass   : KDCustomHTMLView
                      tagName     : 'span'
                      partial     : 'This text is about that feature which is being described in this paragraph.'
                      cssClass    : 'modal-warning'  
    
    @sessionJoinButton = new KDButtonView
      cssClass : 'editor-button clean-gray join-session-button'
      title : 'Join Session'
      callback :=>
        modal = new KDModalViewWithForms
          title                   : "Join a session"
          content                 : ""
          overlay                 : yes
          cssClass                : "new-kdmodal"
          width                   : 500
          height                  : "auto"
          tabs                    : 
            navigable             : yes 
            goToNextFormOnSubmit  : no              
            forms                 :
              "Join Session"  :
                fields          :                      
                  "Notice"      :
                    itemClass   : KDCustomHTMLView
                    tagName     : 'span'
                    partial     : 'Which session do you want to join?'
                    cssClass    : 'modal-info'  
                  "sessionKey"    :
                    label       : 'Session Key'
                    itemClass   : KDInputView
                    name        : 'sessionKey'
                buttons         :  
                  'Join Session'      :
                    title       : 'Okay, thanks!'
                    style       : 'modal-clean-green'
                    loader      :
                      color     : "#ffffff"
                      diameter  : 12
                    callback    : =>
                      console.log 'Session Join Button clicked'
                      if modal.modalTabs.forms['Join Session'].inputs['sessionKey'].getValue() 
                        @ioController.attachFirebase modal.modalTabs.forms['Join Session'].inputs['sessionKey'].getValue(), (sessionKey)=>
                          @sessionShareButton.hide()   
                          @sessionStatus.show()
                          console.log 'FIREBASE: Joined ',sessionKey
                          new KDNotificationView
                            title : 'You joined a KodeLecture session'
                            content : 'Now, you will be able to collaborate with everyone else in this session.'
                            duration : 5000
                          @editorContainer.$().html ''
                          @buildCodeMirror()
                          @firepad = Firepad.fromCodeMirror @ioController.firebaseRef, @codeMirrorEditor, userId: KD.whoami().profile.nickname
                          modal.destroy()
                        
                  Cancel        :
                    title       : 'Cancel'
                    type        : 'modal-cancel'
                    callback    : =>
                      modal.destroy()        

    @broadcastSwitch = new KDOnOffSwitch
      label : new KDLabelView
        title : "Broadcast: "
      size: "tiny"
      defaultValue : yes
      callback:(state)=>
        @ioController.allowBroadcast = state
        
    @sessionStatus = new SessionStatusView
      cssClass : 'session-status'
    
    @sessionStatus.hide()
    
    @chatView = new ChatView
      cssClass : 'chat-view'
       
    @chatView.hide()
    
    @ownTerminal = new KDButtonView
      title : 'My Terminal'
      cssClass : 'clean-gray editor-button my-terminal active'
      tooltip : 
        title : 'This terminal runs on your own file system. Be careful what you enter here, it will affect your files.'
      callback :=>
        console.log 'Swapping Terminal to OWN'
        @ownTerminal.setClass 'active'
        @hostTerminal.unsetClass 'active'
        @liveViewer.terminalPreview?.show()
        @liveViewer.terminalStreamPreview?.hide()
    
    @hostTerminal = new KDButtonView
      title : 'Host Terminal'
      tooltip:
        title : 'This is the terminal of the host of this session. Be careful what you type here, it will affect the hosts files.'
      cssClass  : 'clean-gray editor-button host-terminal hidden'
      callback :=>
        console.log 'Swapping Terminal to HOST'
        @hostTerminal.setClass 'active'
        @ownTerminal.unsetClass 'active'
        @liveViewer.terminalPreview?.hide()
        @liveViewer.terminalStreamPreview?.show()   
    
    @terminalButtons = new KDView
      cssClass : 'terminal-buttons'
    
    @terminalButtons.addSubView @ownTerminal
    @terminalButtons.addSubView @hostTerminal
    
    @previewButtons.addSubView @terminalButtons
    
    @controlView.addSubView @languageSelect.options.label
    @controlView.addSubView @languageSelect
    
    #@controlView.addSubView @broadcastSwitch.options.label    
    #@controlView.addSubView @broadcastSwitch 
    
    #@controlView.addSubView @sessionInput.options.label
    @controlView.addSubView @sessionShareButton
    #@controlView.addSubView @sessionInput
    @controlView.addSubView @sessionJoinButton
   
    @controlView.addSubView @sessionStatus
   
    @previewButtons.addSubView @runButton 
    @controlView.addSubView @controlButtons
    
    @liveViewer.setSplitView @splitView
    @liveViewer.setMainView @
    
    #@preview.addSubView @previewButtons
    
    @taskView.setMainView @
    @taskOverview.setMainView @
    @selectionView.setMainView @
   
    @attachListeners()
   
    @utils.wait 2000, =>
      @selectionView.setClass 'animate'
      @splitView.setClass 'animate'
    
  getModeFromLanguage:(language)->
    matrix = 
      php : 'php'
    
    return matrix[language] or language
    

  attachListeners :->
   
   @on 'LectureChanged', (lecture=0)=>   
      console.log '@LectureChanged',lecture,@ioController.isInstructor
      
      @lastSelectedItem = lecture        
      {code,codeFile,language,files,previewType,expectedResults} = @courses[@lastSelectedCourse].lectures[@lastSelectedItem]
      
      @currentFile = if files?.length>0 then files[0] else 'tempfile'
      
      @ioController.readFile @courses, @lastSelectedCourse, @lastSelectedItem, @currentFile, (err,contents)=>
        unless err
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
        
        unless @ioController.isInstructor 
          @terminalButtons.show()
          @hostTerminal.show()
          @liveViewer.previewStreamedTerminal ['Loading Remote Terminal...']
        else @hostTerminal.hide()
      else 
        @terminalButtons.hide()
        @liveViewer.mdPreview?.show()
        @liveViewer.terminalPreview?.hide()
        @liveViewer.terminalStreamPreview?.hide()
        

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
      console.log 'Setting language to:',@getModeFromLanguage language
      @currentLang = language
      @codeMirrorEditor.setOption 'mode', @getModeFromLanguage language
    
    # iocontroller event bindings
    
    @on 'TerminalContents', (lines)=>
      @ioController.broadcastMessage {terminal:lines} 
    
    @ioController.on 'TerminalSessionChanged', (terminalContent)=>
      unless @ioController.isInstructor 
        {lines,timestamp} = terminalContent
        @liveViewer.previewStreamedTerminal JSON.parse lines
        
    @ioController.on 'TerminalSessionEventKeydown', (event)=>
      if @ioController.isInstructor 
        @liveViewer.handleTerminalInput event, 'keydown'      
        
    @ioController.on 'TerminalSessionEventKeypress', (event)=>
      if @ioController.isInstructor 
        @liveViewer.handleTerminalInput event, 'keypress'        

    @ioController.on 'TerminalSessionEventKeyup', (event)=>
      if @ioController.isInstructor 
        @liveViewer.handleTerminalInput event, 'keyup'
        
    @ioController.on 'LanguageChanged', (language)=> 
      @languageSelect.setValue language
      @emit 'LanguageChanged', language
      
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
      if lecture.previewType is 'terminal' then @terminalButtons.show() else @terminalButtons.hide()

      unless lecture.title is @courses?[@lastSelectedCourse]?.lectures?[@lastSelectedItem]?.title
        console.log 'SYNC: Nope, changing to the lecture'
        @utils.wait 0, => 
          index = 0
          if @courses[@lastSelectedCourse]? then index = i for lecture_,i in @courses[@lastSelectedCourse].lectures when lecture.title is lecture_.title
          @emit 'LectureChanged', index
      else 
        console.log 'SYNC: I am already there'
    
    @ioController.on 'UserJoined', (user)=>
      @chatView.show()
      console.log 'FIREBASE: User Joined:',user
      unless KD.whoami().profile.nickname is user
        if @ioController.isInstructor
          @sessionJoinButton.hide()
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
      console.log 'FIREBASE: User Left:',user
      @sessionStatus.emit 'UserLeft', user
    
    @ioController.on 'ChatMessageArrived', (data)=>
      #data.isInstructor = data.nickname is @ioController.instructor
      @chatView.emit 'ChatMessageArrived', data
    
    @chatView.on 'ChatMessageComposed', (message)=>
      @ioController.broadcastMessage {chat:{message,nickname:KD.whoami().profile.nickname}}
    
    # SHutdown cleanup
    @on "KDObjectWillBeDestroyed", =>
      @ioController.allowBroadcast = no
      @finished = true
      console.log 'Application closing. Cleaning up.'
      @ioController.broadcastMessage {leave:KD.whoami().profile.nickname}

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
    {{> @chatView}}
    {{> @splitViewWrapper}}
    """
    
  viewAppended:->
    @delegateElements()
    @setTemplate do @pistachio