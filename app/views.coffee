{Settings, Ace}   = KodeLectures
{LiveViewer, TaskView} = KodeLectures.Core

# If we want to throw some mad keyboard event magic around, this will help

#require ["https://raw.github.com/termi/DOM-Keyboard-Event-Level-3-polyfill/0.4/DOMEventsLevel3.shim.js"], (domPolyfill)=>
  #console.log 'Polyfill loaded.'


# Comment Box Protoype

# -----------------------------.
#                              |
# -----------------------------|
#                              |
#                              |
#                              |
# ____________________________/


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
    
    @autoScroll         = yes
    @currentLecture     = 0           # Index of the current lecture in the current course
    @currentFile        = ''          # current file to be displayed in the editor, base path is the course directory
    @lastSelectedCourse = 0           # Index of the current course (in the @courses array)
    @viewState          = 'courses'   # State of the window, showing either courses or lectures
    @courses            = []          # Will be populated with imported courses / courses found in /courses directory

    @ioController = new KodeLectures.Controllers.FileIOController  # handles all file/firebase interaction

    @delegateElements()               # attach views to the mainView

    @ioController.emit 'CourseImportRequested'
    
    @ioController.on 'NewCourseImported', (course)=>
      @selectionView.emit 'NewCourseImported', course
      @courses.push course
    
    @ioController.on 'CourseFilesReset', (course)=>
      @emit 'LectureChanged', @lastSelectedItem

    @ioController.attachFirebase null, (sessionKey,state)=>
      if state is 'fresh'
        console.log 'Firebase successfully attached and instantiated. Session key is',sessionKey
        @sessionStatus?.emit 'FirebaseAttached'

  
  save:->
    @ioController.saveFile @courses,@lastSelectedCourse,@lastSelectedItem, @currentFile, @codeMirrorEditor.getValue()  
  
  
  buildCodeMirror:->
    @codeMirrorEditor = CodeMirror @editorContainer.$()[0],
      lineNumbers                : true
      mode                       : "javascript"
      tabSize                    : options.tabSize            or 2
      lineNumbers                : options.lineNumbers        or yes
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
        # Initial firepad (empty)
        @firepad = Firepad.fromCodeMirror @ioController.firebaseRef, @codeMirrorEditor, userId: KD.whoami().profile.nickname
        
        @firepad.on "ready", =>
          if @firepad.isHistoryEmpty()
            @firepad.setText ""
            
    @taskView = new TaskView 
      delegate : @
    , @courses[@lastSelectedCourse or 0]?.lectures?[0] or {}
   
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
      tooltip     :
        title     : 'Save and Run your code (Shift-Alt-R)'
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
      tooltip     :
        title     : 'Go to the course list'
      callback    : (event)=> 
        @emit 'CourseRequested'
        @ioController.broadcastMessage {location:'courses'}
        
    @controlButtons.addSubView @lectureButton = new KDButtonView
      cssClass    : "clean-gray editor-button control-button previous"
      title       : 'Lecture'
      tooltip     :
        title     : 'Go to the current lecture'
      callback    : (event)=> 
        @emit 'LectureRequested' if @lastSelectedCourse
        @ioController.broadcastMessage {location:'lectures'}

     @languageSelect = new KDSelectBox
      label         : new KDLabelView
        title       : 'Language: '      
      selectOptions : [
        {title:'JavaScript',    value:'javascript'}
        {title:'CoffeeScript',  value:'coffeescript'}
        {title:'Shell',         value:'shell'}
        {title:'PHP',           value:'php'}
        {title:'Python',        value:'python'}
        {title:'Ruby',          value:'ruby'}
      ]
      title         : 'Language Selection'
      defaultValue  : 'JavaScript'
      cssClass      : 'control-button language'
      callback      : (item)=>
        @emit 'LanguageChanged', item
        @ioController.broadcastMessage {'language':item}
        
    @currentLang = @courses[@lastSelectedCourse or 0]?.lectures?[0]?.language or 'text'

    @sessionShareButton = new KDButtonView
      cssClass  : 'editor-button clean-gray join-session-button'
      title     : 'Create Session'
      callback  : =>
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
              "Share Session"     :
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
      cssClass  : 'editor-button clean-gray join-session-button'
      title     : 'Join Session'
      callback  : =>
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
              "Join Session"      :
                fields            :                      
                  "Notice"        :
                    itemClass     : KDCustomHTMLView
                    tagName       : 'span'
                    partial       : 'Which session do you want to join?'
                    cssClass      : 'modal-info'  
                  "sessionKey"    :
                    label         : 'Session Key'
                    itemClass     : KDInputView
                    name          : 'sessionKey'
                buttons           :  
                  'Join Session'  :
                    title         : 'Join this Session!'
                    style         : 'modal-clean-green'
                    loader        :
                      color       : "#ffffff"
                      diameter    : 12
                    callback      : =>
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
                  Cancel          :
                    title         : 'Cancel'
                    type          : 'modal-cancel'
                    callback      : =>
                      modal.destroy()        

    @broadcastSwitch = new KDOnOffSwitch
      label         : new KDLabelView
        title       : "Broadcast: "
      size          : "tiny"
      defaultValue  : yes
      callback      : (state)=>
        @ioController.allowBroadcast = state
        
    @sessionStatus = new SessionStatusView
      cssClass      : 'session-status'
    
    @sessionStatus.hide()
    
    @chatView = new ChatView
      cssClass      : 'chat-view'
       
    @chatView.hide()
    
    @ownTerminal = new KDButtonView
      title         : 'My Terminal'
      cssClass      : 'clean-gray editor-button my-terminal active'
      tooltip       : 
        title       : 'This terminal runs on your own file system. Be careful what you enter here, it will affect your files.<br /><hr /><strong>If this button is flashing, you are streaming the contents of your terminal to everyone else in this session.</strong><br /><hr />Click the settings icon to adjust who can see/interact with your terminal.'
      callback      : =>
        console.log 'Swapping Terminal to OWN'
        @ownTerminal.setClass 'active'
        @hostTerminal.unsetClass 'active'
        @liveViewer.terminalPreview?.show()
        @liveViewer.terminalStreamPreview?.hide()
    
    @ownTerminal.addSubView @ownTerminalSettings = new KDButtonView
      icon : yes
      iconOnly : yes
      iconClass : 'cog'
      cssClass : 'my-terminal-settings'
      callback:=>
        modal = new KDModalViewWithForms
          title                   : "My Terminal Settings"
          content                 : ""
          overlay                 : yes
          cssClass                : "new-kdmodal"
          width                   : 500
          height                  : "auto"
          tabs                    : 
            navigable             : yes 
            goToNextFormOnSubmit  : no              
            forms                 :      
              'Streaming'         :
                fields            :
                  AllowStreamingExp:
                    itemClass : KDCustomHTMLView
                    partial : 'Turning on Terminal streaming will allow everyone who joins your session to see your terminal, input and output.'
                    cssClass : 'modal-info'
                  'Allow Streaming' : 
                    itemClass     : KDOnOffSwitch
                    defaultValue  : if @liveViewer.terminalPreview then @liveViewer.terminalPreview.allowStreaming else on
                    callback:(state)=>
                      @liveViewer.terminalPreview?.allowStreaming = state
                      @emit 'OwnTerminalSettingsChanged'
                  AllowStreamingINputExp:
                    itemClass : KDCustomHTMLView
                    partial : 'Turning on Terminal Input streaming will allow everyone who joins your session interact with your terminal. Make sure the users connected to your terminal are aware of the potential harm they can cause.'
                    cssClass : 'modal-warning'                      
                  'Allow remote input':
                    itemClass     : KDOnOffSwitch
                    defaultValue  : if @liveViewer.terminalPreview then @liveViewer.terminalPreview.allowStreamingInput else on
                    callback      : (state)=>
                      @liveViewer.terminalPreview?.allowStreamingInput = state    
                      @emit 'OwnTerminalSettingsChanged'
    
    @hostTerminal = new KDButtonView
      title         : 'Host Terminal'
      tooltip       :  
        title       : 'This is the terminal of the host of this session. Be careful what you type here, it will affect the hosts files.'
      cssClass      : 'clean-gray editor-button host-terminal hidden'
      callback      : =>
        console.log 'Swapping Terminal to HOST'
        @hostTerminal.setClass 'active'
        @ownTerminal.unsetClass 'active'
        @liveViewer.terminalPreview?.hide()
        @liveViewer.terminalStreamPreview?.show()   
    
    @terminalButtons = new KDView
      cssClass      : 'terminal-buttons'
    
    # View construction
    @terminalButtons.addSubView @ownTerminal
    @terminalButtons.addSubView @hostTerminal
    
    @previewButtons.addSubView @terminalButtons
    
    @controlView.addSubView @languageSelect.options.label
    @controlView.addSubView @languageSelect
    
    @languageSelect.options.label.hide()
    @languageSelect.hide()
  
    @controlView.addSubView @sessionShareButton
    @controlView.addSubView @sessionJoinButton
   
    @controlView.addSubView @sessionStatus
   
    @previewButtons.addSubView @runButton 
    @controlView.addSubView @controlButtons
    
    @liveViewer.setSplitView @splitView
    @liveViewer.setMainView @
    
    @taskView.setMainView @
    @taskOverview.setMainView @
    @selectionView.setMainView @
   
    @attachListeners()
   
    @utils.wait 2000, =>
      # delayed animtion for the lecture/course views. will make loading the app less buggy.
      # it would usually jump around then setting the initial 'left' values and such.
      @selectionView.setClass 'animate'
      @splitView.setClass 'animate'
  
  
  # ------------------------------.
  # getModeFromLanguage           |
  # ------------------------------|
  #   CodeMirrors modes allow for |
  #   many different ways of      |
  #   using MIME types. Set here. |
  # _____________________________/
  
  getModeFromLanguage:(language)->
    matrix = 
      php : 'php'
    
    return matrix[language] or language
 
 
  attachListeners :->

    @on 'LectureChanged', (lecture=0)=>   
      console.log "Lecture Changed to ##{lecture}, am I the host? #{@ioController.isInstructor.toString()}"
      
      @lastSelectedItem = lecture        
      {code,codeFile,language,files,previewType,expectedResults} = @courses[@lastSelectedCourse].lectures[@lastSelectedItem]
      
      @currentFile = if files?.length>0 then files[0] else 'tempfile'
      
      @ioController.readFile @courses, @lastSelectedCourse, @lastSelectedItem, @currentFile, (err,contents)=>
        unless err
          @codeMirrorEditor.setValue contents if @ioController.isInstructor
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
          type        : previewType
          coursePath  : @courses[@lastSelectedCourse].path
        
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
        console.log "Course Changed to #{course.title}"
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
    
    
    @on 'JoinSessionFromQuery', (sessionKey)=>
        
      @ioController.parseSessionKey sessionKey, (err,account)=>
        if err then new KDNotificationView title : 'There is a problem with the host of the requested session. Try manually joining that session.'
        else modal = new KDModalViewWithForms
          title                   : "Join a KodeLecture session"
          content                 : ""
          overlay                 : yes
          cssClass                : "new-kdmodal session-request-modal"
          width                   : 500
          height                  : "auto"
          tabs                    : 
            navigable             : yes 
            goToNextFormOnSubmit  : no              
            forms                 :
              "Join Session"      :
                fields            :                      
                  "Notice"        :
                    itemClass     : KDCustomHTMLView
                    tagName       : 'span'
                    partial       : "You are about to join a KodeLecture session.<br /><br />This session belongs to <strong>#{account.profile.firstName} #{account.profile.lastName}</strong>. <br /> <br />You can collaborate on any lecture the host activates. If you don't have these lectures installed, they will be automatically imported when they are needed."
                    cssClass      : 'modal-info'  
                  "sessionKey"    :
                    label         : 'Session Key'
                    itemClass     : KDInputView
                    defaultValue  : sessionKey
                    disabled      : yes
                    name          : 'sessionKey'
                buttons           :  
                  'Join Session'  :
                    title         : 'Join this Session!'
                    style         : 'modal-clean-green'
                    loader        :
                      color       : "#ffffff"
                      diameter    : 12
                    callback      : =>
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
                  Cancel          :
                    title         : 'Cancel'
                    type          : 'modal-cancel'
                    callback      : =>
                      modal.destroy()      
    
    # ------------------------------------.
    # ioController event bindings         |
    # ------------------------------------|
    #   - handles all events that come    |
    #     from firebase and are for-      |
    #     warded there.                   |
    # ___________________________________/
    
    @on 'TerminalContents', (lines)=>
      @ioController.broadcastMessage {terminal: lines} 
    
    @ioController.on 'TerminalSessionChanged', (terminalContent)=>
      unless @ioController.isInstructor 
        {lines,timestamp} = terminalContent
        @liveViewer.previewStreamedTerminal JSON.parse Encoder.htmlDecode window.atob lines
        
    @ioController.on 'TerminalSessionEventKeydown', (event)=>
      if @ioController.isInstructor 
        @liveViewer.handleTerminalInput event, 'keydown'      
        
    @ioController.on 'TerminalSessionEventKeypress', (event)=>
      if @ioController.isInstructor 
        @liveViewer.handleTerminalInput event, 'keypress'   
        
    @ioController.on 'TerminalSessionEventPaste', (event)=>
      if @ioController.isInstructor 
        @liveViewer.handleTerminalInput event, 'paste'        
        
    @ioController.on 'LanguageChanged', (language)=> 
      @languageSelect.setValue language
      @emit 'LanguageChanged', language
      
    @ioController.on 'LectureRequested', => @emit 'LectureRequested' unless @viewState is 'lectures'
    
    @ioController.on 'CourseRequested', => @emit 'CourseRequested' unless @viewState is 'courses'
    
    @ioController.on 'EditorContentChanged', ({text,origin})=> # deprecated


    # -----------------------------.
    # firebase CourseChanged       |
    # -----------------------------|
    #   Check if course exists. If |
    #   not, import it, else  fire |
    #   it up and go to the first  |
    #   lecture.                   |
    # ____________________________/


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
      @ioController.isBroadcasting = yes
      @emit 'OwnTerminalSettingsChanged'
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
      @chatView.emit 'ChatMessageArrived', data
    
    @chatView.on 'ChatMessageComposed', (message)=>
      @ioController.broadcastMessage 
        chat        :
          timestamp : new Date().getTime()
          message   : message
          nickname  : KD.whoami().profile.nickname

    @on 'OwnTerminalSettingsChanged', =>
      if @liveViewer.terminalPreview?.allowStreaming and @ioController.isBroadcasting
        @ownTerminal.setClass 'streaming'
      else @ownTerminal.unsetClass 'streaming'
      
      
      
      
    # -----------------.
    # Shutdown cleanup |
    # ________________/
    
    @on "KDObjectWillBeDestroyed", =>
      console.log 'Application closing. Cleaning up.'
      
      #Send a leave message, so all connected clients can update their views/connections
      @ioController?.broadcastMessage {leave:KD.whoami().profile.nickname}

      # Stop all broadcasting that is still going on
      @utils.wait 50, => @ioController.allowBroadcast = no

      @finished = true
      
      # Close the terminal connection to prevent idle conenctions
      @liveViewer?.terminalPreview?.server?.close?()

    # Resize hack for nested splitviews    
    @splitView.on 'ResizeDidStart', =>
      @resizeInterval = KD.utils.repeat 100, =>
        @taskSplitView._windowDidResize {}
        
    @splitView.on 'ResizeDidStop', =>
      KD.utils.killRepeat @resizeInterval
      @taskSplitView._windowDidResize {}

  pistachio:-> 
    """
    {{> @controlView}}
    {{> @chatView}}
    {{> @splitViewWrapper}}
    """
    
  viewAppended:->

    @setTemplate do @pistachio