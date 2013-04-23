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
  
  #pistachios: /\{(\w*)?(\#\w*)?((?:\.\w*)*)(\[(?:\b\w*\b)(?:\=[\"|\']?.*[\"|\']?)\])*\{([^{}]*)\}\s*\}/g
  
  constructor: ()->
    @sessionId = KD.utils.uniqueId "kodepadSession"
  
  setPreviewView: (@previewView)->
    unless @mdPreview
      @previewView.addSubView @mdPreview = new KDView
        cssClass : 'has-markdown markdown-preview'
        partial : '<div class="info"><pre>When you run your code, you will see the results here</pre></div>'
    else 
      @mdPreview?.show() 
      @terminalPreview?.hide()
    
  setSplitView: (@splitView)->
    
  setMainView: (@mainView)->
  
  handleTerminalInput:(event,type)->
    if @terminalPreview

      if type is 'keydown'
        eventObj = if document.createEventObject then document.createEventObject() else document.createEvent("Events")
    
        if eventObj.initEvent
          eventObj.initEvent("keydown", true, true)
      
        eventObj.key     = event.key or 0
        eventObj.char    = event.char or 0
        eventObj.charCode = event.charCode or 0 #or event.keyCode
        eventObj.keyCode = event.keyCode or 0
        eventObj.which = event.which or 0
        eventObj.shiftKey = event.shiftKey or no
        eventObj.metaKey = event.metaKey or no
        eventObj.altKey = event.altKey or no
        eventObj.ctrlKey = event.ctrlKey or no
        
        console.log 'resulting event:',eventObj
        @terminalPreview.keyDown eventObj 
      
      else if type is 'keypress'
        eventObj1 = if document.createEventObject then document.createEventObject() else document.createEvent("Events")
    
        if eventObj1.initEvent
          eventObj1.initEvent("keypress", true, true)
      
        eventObj1.key     = event.key or 0
        eventObj1.char    = event.char or 0
        eventObj1.charCode = event.charCode or 0 #or event.keyCode
        eventObj1.keyCode = event.keyCode or 0
        eventObj1.which = event.which or 0
        eventObj1.shiftKey = event.shiftKey or no
        eventObj1.metaKey = event.metaKey or no
        eventObj1.altKey = event.altKey or no
        eventObj1.ctrlKey = event.ctrlKey or no

        console.log 'resulting event:',eventObj1
        @terminalPreview.keyPress eventObj1
      #
      #console.log 'TERMINAL: this should be forwarded',event,eventObj,event.charCode, event.keyCode
  
  previewStreamedTerminal: (lines,forceShow=no)->
    
    lines = lines.join "<br />"
    try
      unless @terminalStreamPreview
        console.log 'TERMINAL: Adding streaming Terminal'
        @previewView.addSubView @terminalStreamPreview = new KDView
          cssClass : 'webterm terminal terminal-stream-preview'
        
        @terminalStreamConsole = new KDView
          cssClass : 'console ubuntu-mono green-on-black'
          partial : lines
        
        @terminalStreamTextarea = new KDInputView
          type : 'textarea'
          cssClass : 'terminal-textarea'
          bind : 'click keyup keypress keydown paste'
          callback : =>
            console.log 'Input Callback'
        
        @terminalStreamTextarea.on 'click', (event)=>
          @terminalStreamTextarea.setFocus()
        
        @terminalStreamTextarea.on 'keyup', (event)=>
          event.preventDefault()
          event.stopPropagation()
          
          @mainView.ioController.broadcastMessage
            terminalEventKeyup :
              altKey : event.altKey or false
              ctrlKey : event.ctrlKey or false
              metaKey : event.metaKey or false
              charCode : event.charCode or 0
              keyCode : event.keyCode or 0
              shiftKey : event.shiftKey or false
              which : event.which or 0
              key   : event.key or 0
              char  : event.char or 0
          
          console.log 'REMOTE: keyup detected',event
          @terminalStreamTextarea.setValue ''            
        
        @terminalStreamTextarea.on 'keydown', (event)=>
          event.preventDefault()
          event.stopPropagation()
          
          @mainView.ioController.broadcastMessage
            terminalEventKeydown :
              altKey : event.altKey or false
              ctrlKey : event.ctrlKey or false
              metaKey : event.metaKey or false
              charCode : event.charCode or 0
              keyCode : event.keyCode or 0
              shiftKey : event.shiftKey or false
              which : event.which or 0
              key   : event.key or 0
              char  : event.char or 0
          
          console.log 'REMOTE: keydown detected',event
          @terminalStreamTextarea.setValue ''        

        @terminalStreamTextarea.on 'keypress', (event)=>
          event.preventDefault()
          event.stopPropagation()
          
          @mainView.ioController.broadcastMessage
            terminalEventKeypress :
              altKey : event.altKey or false
              ctrlKey : event.ctrlKey or false
              metaKey : event.metaKey or false
              charCode : event.charCode or 0
              keyCode : event.keyCode or 0
              shiftKey : event.shiftKey or false
              which : event.which or 0
              key   : event.key or 0
              char  : event.char or 0
          
          console.log 'REMOTE: keypress detected',event
          @terminalStreamTextarea.setValue ''        
          
        @terminalStreamTextarea.on 'paste', (event)=>
          
          pasted = @terminalStreamTextarea.getValue() 
          console.log 'REMOTE: paste detected',event
          @terminalStreamTextarea.setValue ''
        
          event.preventDefault()
          event.stopPropagation()
        
        @terminalStreamPreview.addSubView @terminalStreamConsole
        @terminalStreamPreview.addSubView @terminalStreamTextarea
      
      else 
        @terminalStreamConsole.updatePartial lines
        
    @terminalStreamConsole.$().scrollTop @terminalStreamConsole.$()[0].scrollHeight
    
    if forceShow
      @mdPreview?.hide()
      @terminalPreview?.hide()
      @terminalStreamPreview?.show()
  
  previewCode: (code, execute, options)->
    return if not @active 
    if code or code is ''
    
      KD.utils.killRepeat @terminalStream if @terminalStream

      kiteController = KD.getSingleton "kiteController"

      {ioController,courses,lastSelectedCourse:course,lastSelectedItem:lecture} = @mainView
      
      ioController.runFile courses,course,lecture,execute, (err,res)=>
      
        @mainView.taskView.emit 'ResultReceived',res unless err
        
        {type,previewPath,coursePath} = options
       
        type ?= 'code-preview'
  
        # ======================
        # CODE-PREVIEW
        # ======================
        
        if type is 'code-preview'
          window.appView = @previewView
        
          if res is '' then text = '<div class="info"><pre>KodeLectures received an empty response but no error.</pre></div>'
          else text = if err then "<div class='error'><pre>#{err.message}</pre></div>" else "<div class='success'><pre>#{Encoder.XSSEncode res}</pre></div>"
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
            @mdPreview?.show()
            @terminalPreview?.hide()
            @terminalStreamPreview.hide()
            delete window.appView
       
        # ======================
        # EXECUTE-HTML
        # ======================

        else if type is 'execute-html'

          window.appView = @previewView

          ioController.generateSymlinkedPreview previewPath, coursePath, (err,res,publicURL) =>
            console.log err if err
            console.log "Course preview path '#{previewPath}' symlinked to '#{publicURL}'" unless err
          
            partial ="<div class='result-frame'><iframe src='#{publicURL}'></iframe></div>"
        
            try
              unless @mdPreview
                @previewView.addSubView @mdPreview = new KDView
                  cssClass : 'has-markdown markdown-preview'
                  partial : partial
              else 
                @mdPreview.updatePartial partial
          
            catch error
              notify error.message
            finally
              @mdPreview?.show()
              @terminalPreview?.hide()
              @terminalStreamPreview?.hide()
              delete window.appView
        
        # ======================
        # TERMINAL
        # ======================

        else if type is 'terminal'
          console.log 'Terminal requested.'
          window.appView = @previewView
        
          sendCommand = (command)=>
            if @terminalPreview.terminal?.server?.input
              @terminalPreview.terminal?.server?.input command+"\n" unless command is ''
              KD.utils.defer => @terminalPreview.emit 'click' # focus :)
            else console.log 'There is a connectivity problem with the terminal'  
          unless @terminalPreview
              console.log 'Adding terminal. This should only happen once.'
              appStorage = new AppStorage 'KodeLectures', '1.0'
              appStorage.fetchStorage (storage)=>
                @previewView.addSubView @terminalPreview = new WebTermView appStorage
                @terminalPreview.setClass 'webterm'
                console.log 'Terminal added successfully.'
                @terminalPreview.show()
                @mdPreview?.hide()
                @terminalStreamPreview?.hide()
                delete window.appView  

                # this is hacky. where did the connected event go?
                KD.utils.wait 2000, =>    
                  initialCommand = "cd 'Applications/KodeLectures.kdapp/courses/#{coursePath}'"
                  console.log 'Sending initial command to terminal',initialCommand
                  sendCommand initialCommand
                  KD.utils.defer => 
                    console.log 'Sending command to terminal',code
                    sendCommand code
                            
          else 
              console.log 'Send command to terminal',code
              sendCommand code     
              
              @terminalPreview?.show()
              @mdPreview?.hide()   
              @terminalStreamPreview?.hide()
              delete window.appView       
        
          if @mainView.ioController.isInstructor then @terminalStream = KD.utils.repeat 2500, =>         
            lines = (line[0].innerHTML for line in @terminalPreview.terminal.screenBuffer.lineDivs)
            KD.utils.killRepeat @terminalStream if @mainView.finished
            @mainView.emit "TerminalContents", JSON.stringify lines
 

class KodeLectures.Views.TaskSubItemView extends KDListItemView
  constructor:->
    super
    
    {cssClass} = @getData()
    
    @setClass cssClass
    
    @header = new KDCustomHTMLView
      tagName : 'span'
      cssClass : 'text'
      click :=>
        @content.show()
  
    @content = new KDCustomHTMLView
      tagName : 'span'
      cssClass : 'data'
 
    @updateViews @getData() 
 
  updateViews:(data)->
    
    {title,content,headerHidden,contentHidden} = data
    {type,title:initialTitle,content:initialContent,contentHidden:initialContentHidden,headerHidden:initialHeaderHidden} = @getData()
    
    @header.updatePartial title or initialTitle
    
    contentPartial = switch type
      when 'lectureText','taskText','codeHint','codeHintText' then marked(content or initialContent)
      when 'embed' then if content.type is 'youtube' then """<iframe src="#{content.url}" frameborder="0" allowfullscreen></iframe>"""
    
    @content.updatePartial contentPartial
    
    headerHidden ?= initialHeaderHidden
    contentHidden ?= initialContentHidden
    
    if headerHidden then @header.hide() else @header.show()
    if contentHidden then @content.hide() else @content.show()
  
    unless type isnt 'embed' and content and content isnt '' or type is 'embed' and content?.url? 
      @hide() 
    else 
      @show()
  
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
  
  pistachio:->
    """
    {{> @header}}
    {{> @content}}
    """  

class KodeLectures.Views.TaskView extends JView
  {TaskSubItemView} = KodeLectures.Views
  setMainView: (@mainView)->

  constructor:->
    super
    @setClass 'task-view'
  
  
    {videoUrl,@codeHintText,@codeHint,embedType,@taskText,@lectureText} = @getData()
    @codeHint ?= ''
    @codeHintText ?= ''
    @taskText ?= ''
    @lectureText ?= ''
    
    @subItemController = new KDListViewController
      itemClass : TaskSubItemView
      delegate  : @
      
    @subItemList = @subItemController.getView()
        
    @subItemEmbed = @subItemController.addItem 
      type          : 'embed'
      title         : ''
      content       : 
        url         : videoUrl
        type        : embedType
      cssClass      : 'embed'
      contentHidden : no
      headerHidden  : yes

    @subItemLectureText = @subItemController.addItem
      type          : 'lectureText'
      title         : 'Lecture'
      content       : @lectureText
      cssClass      : 'lecture-text-view has-markdown'
      contentHidden : no
      headerHidden  : yes
    
    @subItemTaskText = @subItemController.addItem
      type          : 'taskText'
      title         : 'Assignment'
      content       : @taskText
      cssClass      : 'task-text-view has-markdown'
      contentHidden : no
    
    @subItemHintText = @subItemController.addItem
      type          : 'codeHintText'
      title         : 'Hint'
      content       : @codeHintText
      cssClass      : 'hint-view has-markdown'
      contentHidden : yes
    
    @subItemHintCode = @subItemController.addItem
      type          : 'codeHint'
      title         : 'Solution'
      content       : @codeHint
      cssClass      : 'hint-code-view has-markdown' 
      contentHidden : yes
  
    @nextLectureButton = new KDButtonView
      title : 'Next Lecture'
      cssClass : 'cupid-green hidden fr task-next-button'
      callback :=>
        @mainView.emit 'NextLectureRequested'
 
    @resultView = new KDView
      cssClass : 'result-view hidden'
         
    @on 'LectureChanged',(lecture)=>
      
      
      {@codeHint,@codeHintText,@taskText,@lectureText,videoUrl,embedType}=lecture
      @setData lecture
      @resultView.hide()
      @nextLectureButton.hide()
      @mainView.liveViewer.active = no
      @mainView.liveViewer.mdPreview?.updatePartial '<div class="info"><pre>When you run your code, you will see the results here</pre></div>'
      
      @subItemEmbed.updateViews
        content       : 
          url         : videoUrl
          type        : embedType
        headerHidden  : yes
      
      @subItemLectureText.updateViews
        content : @lectureText
      
      @subItemTaskText.updateViews
        content : @taskText
      
      @subItemHintText.updateViews
        content : @codeHintText
      
      @subItemHintCode.updateViews
        content : @codeHint
      
      @render()
    
    @on 'ResultReceived', (result)=>
      
      {expectedResults,submitSuccess,submitFailure} = @getData()
      
      @resultView.show() unless expectedResults is null
      
      if result.trim() is expectedResults
        @resultView.updatePartial submitSuccess
        @resultView.setClass 'success'
        @nextLectureButton.show()
      else 
        @resultView.updatePartial submitFailure
        @resultView.unsetClass 'success'  
 
    @on 'ReadyForNextLecture', =>
      @nextLectureButton.show()
  
    @on 'HideNextLectureButton', =>
      @nextLectureButton.hide()
 
  pistachio:->
    """
    {{> @nextLectureButton}}
    {{> @resultView }}    
    {{> @subItemList}}
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
      @mainView.emit 'LectureChanged',@lectureListController.itemsOrdered.indexOf item 
    
    @on 'LectureChanged', ({course,index})=>
      
      @lectureListController.removeAllItems()
      @lectureListController.instantiateListItems course.lectures
      
      @getDelegate().ioController.broadcastMessage {lecture:course.lectures[index],course:course}
      
      item.unsetClass 'active' for item in @lectureListController.itemsOrdered 
      @lectureListController.itemsOrdered[index].setClass 'active'
  
  setMainView:(@mainView)->
  
  pistachio:->
    """
    {{> @lectureList}}
    """

class KodeLectures.Views.CourseLectureListItemView extends KDListItemView
  
  constructor:->
    super
    
    @lectureTitle = new KDView 
      cssClass : 'lecture-listitem'
      partial : Encoder.XSSEncode @getData().title
  
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
  
  pistachio:->
    """
    {{> @lectureTitle}}
    """
  
  click:(event)->
    event.stopPropagation()
    event.preventDefault()
    @getDelegate().emit 'LectureSelected', @getData()
    
    
class KodeLectures.Views.CourseSelectionItemView extends KDListItemView  
  {CourseLectureListItemView} = KodeLectures.Views
  constructor:->
    super
    @setClass 'selection-listitem'

    lectureCount = @getData().lectures.length
    
    author = @getData().author or 'unknown author'
    
    @titleText = new KDView
      partial   : "<span>#{Encoder.XSSEncode @getData().title}</span><span class='lectures'>#{lectureCount} lecture#{if lectureCount is 1 then '' else 's'} by #{Encoder.XSSEncode author}</span>"
      cssClass  : 'title'
      
    @descriptionText = new KDView
      partial   : Encoder.XSSEncode  @getData().description
      cssClass  : 'description'
  
    @lectureController = new KDListViewController
      itemClass : CourseLectureListItemView
      delegate  : @ 
    , items     : @getData().lectures
    @lectureList = @lectureController.getView()
  
    @lectureController.listView.on 'LectureSelected', (data)=>
      @getDelegate().emit 'LectureSelected', {lecture:data, course:@getData()}
      #@getDelegate().ioController.broadcastMessage {lecture:data, course:@getData()}
      
    @titleText.addSubView @settingsButton = new KDButtonView
      style               : 'course-settings-menu editor-advanced-settings-menu fr'
      icon                : yes
      iconOnly            : yes
      iconClass           : "cog"
      callback            : (event)=>

        contextMenu       = new JContextMenu
          event           : event
          delegate        : @
        ,

        'Remove Course'   :
          callback        : (source, event)=>
            contextMenu.destroy()
            modal         = new KDModalView
              cssClass    : 'lecture-modal'
              title       : 'Remove Course'
              content     : 'Do you really want to remove this course and all its files? All the changes you made will be deleted alongside the lectures. You will have to re-import the course to open it again.'
              buttons     :
                "Remove Course completely":
                  title   : 'Remove Course completely'
                  cssClass: 'modal-clean-red'
                  callback: =>
                    @getDelegate().emit 'RemoveCourseClicked',{course:@getData(),view:@}
                    modal.destroy()
                Cancel    :
                  cssClass: 'modal-cancel'
                  title   : 'Cancel'
                  callback: =>
                    modal.destroy()
                
        'Reset Course files':
          callback        : (source, event)=>                
            contextMenu.destroy()
            
            if @getData().originType in ['git']
             modal         = new KDModalView
              cssClass    : 'lecture-modal'              
              title       : 'Reset Course Files'
              content     : 'Do you really want to reset all files in this course? All the changes you made will be deleted. The course will revert to the stage it was in when it was imported.'
              buttons     :
                "Reset all files":
                  title   : 'Reset all files'
                  cssClass: 'modal-clean-red'
                  callback: =>
                    console.log 'Resetting'
                    @getDelegate().emit 'ResetCourseClicked',{course:@getData(),view:@}
                    contextMenu.destroy()
                    modal.destroy()
                Cancel    :
                  cssClass: 'modal-cancel'
                  title   : 'Cancel'
                  callback: =>
                    modal.destroy()
            else new KDNotificationView {title:'This Course can not be reset. Try deleting and re-importing it.'}
                
    @firstLectureLink = new KDCustomHTMLView
      partial : 'Get started!'
      cssClass : 'get-started-link'
      click   : (event)=>
        event.preventDefault()
        event.stopPropagation()
        @getDelegate().emit 'LectureSelected', {lecture:@getData().lectures[0], course:@getData()}
        #@getDelegate().ioController.broadcastMessage {'lecture':@getData().lectures[0], 'course': @getData()}
  
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
  
  click:(event)->
    event.stopPropagation()
    event.preventDefault()
    @getDelegate().emit 'CourseSelected', @getData()
    #@getDelegate().ioController.broadcastMessage {'course':@getData()}
  
  pistachio:->
   
    # {{> @lectureList }}
    """
    {{> @titleText}}
    <div class="course-details">
    {{> @descriptionText}}
    {{> @firstLectureLink}}
    </div>
    """
class KodeLectures.Views.ImportCourseRecommendedListItemView extends KDListItemView    
  
  constructor:->
    super
    
    @setClass 'recommended-listitem'
    
    @importButton = new KDButtonView
      cssClass : 'cupid-green recommended-import-button'
      title :'Install this Course'
      callback :=>
        @getDelegate().emit 'ImportClicked',@getData()
    
    @iconView = new KDView
     cssClass : 'recommended-icon'
    
    
    
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
      
  pistachio:->
    """
    {{> @iconView}}
    {{> @importButton}}
    {{ #(title)}}
    {{ #(description)}}
    """
    
class KodeLectures.Views.ImportCourseBar extends JView
  {ImportCourseRecommendedListItemView} = KodeLectures.Views
  constructor:->
    super
    
    @apiURL = 'http://arvidkahl.koding.com/lectures'
    
    @recommendedHeader = new KDView
      cssClass : 'recommended-courses'
      partial:"<h1><strong>Recommended</strong> Courses</h1>"
      click :=>
        if @$().hasClass 'minimized'
          @unsetClass 'minimized'
        else @setClass 'minimized'
      
    
    @recommendedListController = new KDListViewController
      itemClass : ImportCourseRecommendedListItemView
    
    @recommendedList = @recommendedListController.getView()
    @recommendedListController.listView.on 'ImportClicked', (data)=>
      @getDelegate().emit 'ImportRequested', data
    
    @getSingleton('kiteController').run "curl -kL '#{@apiURL}'", (error, data)=>
      
      # if any error exists or data is empty, try JSONP
      if error or not data
        json = $.ajax 
          url         : "#{apiURL}"
          data        : {}
          dataType    : "jsonp"
          success     : callback
      
      # parse the curl result.
      try json = JSON.parse data
      #console.log json
      
      if json?.courses?.length 
        for course in json.courses
          @recommendedListController.addItem course
      
  pistachio:->
    """
    {{> @recommendedHeader}}
    {{> @recommendedList}}
      
    """
    

class KodeLectures.Views.NavBar extends JView

  constructor:->
    super
    @setClass 'nav-bar'
    
    
    @aboutLink = new KDCustomHTMLView
      partial : 'About'
      cssClass : 'nav-link about'
      click:=>
        @getDelegate().emit 'AboutLinkClicked'
        
    @coursesLink = new KDCustomHTMLView
      partial : 'My Courses'
      cssClass : 'nav-link courses'
      click:=>
        @getDelegate().emit 'CoursesLinkClicked'
        
    @recommendedLink = new KDCustomHTMLView
      partial : 'Recommended Courses'
      cssClass : 'nav-link recommended'
      click:=>
        @getDelegate().emit 'RecommendedLinkClicked'
    
  pistachio:->
    """
    <div class='logo'><span class='icon'></span>Kode<span>Lectures</span></div>
      {{> @coursesLink}}
      {{> @recommendedLink}}
      {{> @aboutLink}}
    """

class KodeLectures.Views.CourseSelectionView extends JView
  {CourseSelectionItemView, ImportCourseBar, NavBar} = KodeLectures.Views
  
  constructor:->
    super
    courses = @getData()
    
    @courseController = new KDListViewController
      itemClass : CourseSelectionItemView
      delegate  : @
    , items     : courses
  
    @courseView = @courseController.getView()
    
    @courseEmptyMessage = new KDCustomHTMLView
      tagName : 'span'
      cssClass : 'course-empty-message'
      partial : """Hmm, you don't have any courses here yet. <span>You can import them from the list below or manually with the 'Import Course' button.</span>"""
    
    @on 'NewCourseImported', (course)=>
      @courseController.addItem course
      courses.push course
      @courseEmptyMessage.hide()
    
    @courseController.listView.on 'LectureSelected', ({course,lecture})=>
      @mainView.emit 'CourseChanged', courses.indexOf course
      KD.utils.defer => 
        @mainView.emit 'LectureChanged', course.lectures.indexOf lecture
        @mainView.ioController.broadcastMessage {course,lecture}
        
    @courseController.listView.on 'CourseSelected', (course)=>
      @mainView.emit 'CourseChanged', courses.indexOf course
      KD.utils.defer => 
        @mainView.emit 'LectureChanged', 0
        @mainView.ioController.broadcastMessage {course, lecture:course.lectures[0]}

    @courseController.listView.on 'RemoveCourseClicked', ({course,view})=>
      @mainView.ioController.removeCourse courses, courses.indexOf(course), (err,res)=>
        unless err then view.destroy()
        courses.splice courses.indexOf(course),1
        if courses.length is 0 then @courseEmptyMessage.show()
    
    @courseController.listView.on 'ResetCourseClicked', ({course,view})=>
      @mainView.ioController.resetCourseFiles courses, courses.indexOf(course), course.originType, (err,res)=>
        unless err then new KDNotificationView {title:'Files successfully reset'}
    
    @on 'CoursesLinkClicked', =>
      console.log 'courses',$(".page > div.course-header.page-item").offset().top
      @$().animate
         scrollTop: $(".page > div.course-header.page-item").offset().top-100
      , 1000
          
    @on 'AboutLinkClicked', =>
      console.log 'about',  $(".page > div.about.page-item").offset().top
      @$().animate
         scrollTop: $(".page > div.about.page-item").offset().top-100
      , 1000
    
    @on 'RecommendedLinkClicked', =>
      console.log 'recommended', $(".page > div.import-course-bar.page-item").offset().top
      @$().animate
         scrollTop: $(".page > div.import-course-bar.page-item").offset().top-100
      , 1000
    
    @on 'ImportRequested', (data)=>
      
      courseExists = course for course in courses when course.originUrl is data.url

      {title,type,url} = data

      if courseExists
        modal = new KDModalView
          cssClass : 'lecture-modal'
          title : 'Import a Course'
          content : '<p>The Course you are trying to import is already installed. Do you want to replace the currently installed version?</p><p><strong>Warning</strong>: all your file changes will be lost!</p>'
          buttons :
            "Replace Course":
              title : "Replace Course #{course.title}"
              cssClass : 'modal-clean-red'
              callback : =>
                console.log "Removing old Course #{course.title}"
                modal.destroy()
                @mainView.ioController.removeCourse courses, courses.indexOf(course), (err,res)=>
                  item.destroy() for item in @courseController.itemsOrdered when item.getData().path is course.path
                  if type in ['git']
                    console.log 'Attempting import from',url
                    @mainView.ioController.importCourseFromRepository url, type, =>
                      console.log 'Import started.'
            Cancel :
              title : 'Keep the old Course'
              cssClass : 'modal-cancel'
              callback : =>
                modal.destroy()
                      
  
      else 
        if type in ['git']
          console.log 'Attempting import from ',url
          @mainView.ioController.importCourseFromRepository url, type, =>
            console.log 'Import completed successfully.'
    
    @courseHeader = new KDView
      cssClass : 'course-header page-item'
      partial : '<h1><strong>Your</strong> Courses</h1>'

    @importCourseBar = new ImportCourseBar
      cssClass : 'import-course-bar page-item'
      delegate : @

    @navBar = new NavBar
      delegate : @

  setMainView:(@mainView)->

  pistachio:->
    """
    {{> @navBar}}
    
    <div class="hero">
      <div class="content">
        <span class='video'><!--<iframe width="100%" height="100%" src="http://www.youtube.com/embed/fvsKkwbhfs8" frameborder="0" allowfullscreen></iframe>--></span>
        <span class='title'>Learn. Teach. Code.</span>
        <span class='subtitle'>KodeLectures will allow you to chose from a variety of user-submitted lectures or submit them yourself!</span>
      </div>
    </div>
    <div class="cta-header">
   
    </div>
    <div class="page">

      {{> @courseHeader}}
      {{> @courseEmptyMessage}}
      {{> @courseView}}
      <hr/>
      {{> @importCourseBar}}
      <hr/>
      <div class='about page-item'>
        <h1><strong>About</strong> <span>/ How to use KodeLectures</span></h1>
        <p>
        Hey there! Welcome to KodeLectures! 
        With this Koding app, you can learn from the community and give back by creating courses and lectures yourself. 
        Under <strong>Recommended Courses</strong> you will find a few basic (example) courses. Go ahead, try them out!
        </p>
        <h2>How do I learn?</h2>
        <p>The <strong>Course</strong> is the basic unit of learning. It contains a certain number of <strong>Lectures</strong>, that may have assignments attached to them.
        You can chose to try the assignment, and should you run into trouble, the Course author can provide hints and a solution for each assignment.
        Otherwise, you can read or watch (providing the author has supplied a video) the lectures.</p>
        <p>To be able to start learning, you have to get a hold of courses first. You can do that by importing them from <strong>Recommended Courses</strong> or
        via the <strong>Import Course</strong> button on the top right. Providing a working URL to a <code>kdlecture</code> course will immediately import the Course, ready for action!
        </p>
        <h2>How do I teach?</h2>
        <p>If you are interested in creating Courses, please check out the example repositories of the courses in the <strong>Recommended Courses</strong> section. 
        They will provide you with a fully functional file structure and a <code>manifest.json</code> file, containing all the fields that you just have to modify to create your won courses.
        I created a repository at <a target="_blank" href="https://github.com/arvidkahl/CoffeeScript.kdlecture">https://github.com/arvidkahl/CoffeeScript.kdlecture</a> with a README file that will be constantly updated with any added/modified feature or behavior.
        This repository will always contain a <code>manifest.json</code> file that uses every possible feature of this app. Please feel free to clone the repository, rename it to something unique, write your own lectures and then pass the repository URL to me. 
        I will then include it into the <strong>Recommended Courses</strong> part of this page. 
        <h2>Feedback</h2>
        <p>If you run into trouble using the app, have feature requests, bug reports or anything else, please contact me at <a href='mailto:arvid@koding.com' target='_blank'>arvid@koding.com</a> or at <a href='//twitter.com/arvidkahldev' target='_blank'>@arvidkahldev</a>. My Koding username is <a href="/arvidkahl">@arvidkahl</a>.</p>
      </div>
      <hr/>

    </div>
    """
    
class KodeLectures.Views.SessionStatusView extends JView
  constructor:->
    super
    @text = new KDView
      partial : 'Initializing…'
    
    @userCount = 0
    
    @on "UserJoinedHost", (user)=>
      @setClass 'host'
      @text.updatePartial "#{++@userCount} people connected to your lecture. Last join: #{user}"
    
    @on "UserJoinedSelf", (key)=>
      @setClass 'join'
      @text.updatePartial "You are connected to session #{key} (#{++@userCount})"
    
    @on "UserJoined", (user)=>
      @setClass 'join'
      @text.updatePartial "#{++@userCount} people connected to this session Last join: #{user}"    
    
    @on "UserLeft", (user)=>
      if --@userCount is 0
        @unsetClass 'join'
        @unsetClass 'host'
        @text.updatePartial "Everyone has left this session"
      else 
        @text.updatePartial "#{@userCount} people connected to this session Last join: #{user}"
      
      @utils.defer => if @userCount < 0 then @userCount = 0
    
    @on "FirebaseAttached", =>
      @setClass 'ready'
      @userCount = 0
      @text.updatePartial "You can now share your Session"
      
  pistachio:->  
    """
    <span class="icon"></span>
    {{> @text}}
    """
class KodeLectures.Views.ChatParticipantView extends KDListItemView  
  constructor:->
    super
    
class KodeLectures.Views.ChatMessageView extends KDListItemView
  constructor:->
    super
    
    #console.log 'CHAT: Adding message to chat.'
    
    @setClass 'chat-message-item'
    
    @nickname = new KDCustomHTMLView
      cssClass : 'chat-nickname'
      partial : @getData().nickname+': '
    
    if @getData().isInstructor then @nickname.setClass 'instructor'
    
    @avatar    = new AvatarView
      cssClass : 'chat-avatar'
      size     : 
        height : 30
        width  : 30
    
    KD.remote.cacheable @getData().nickname , (err,account)=>
      unless err 
        @avatar.setData account
        @avatar.render()
    
    @message = new KDCustomHTMLView
      cssClass : 'chat-message'
      partial : Encoder.XSSEncode @getData().message
  
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
  
  click :->
    @getDelegate().emit 'ChatMessageClicked'
  pistachio:->
    """
      {{> @avatar}}
      {{> @nickname}}
      {{> @message}}
    """
     
class KodeLectures.Views.ChatView extends JView    
  {ChatParticipantView, ChatMessageView} = KodeLectures.Views
  constructor :->
    super
    
    messagesController = new KDListViewController
      view : @messagesList = new KDListView
        cssClass : 'chat-messages'
        itemClass : ChatMessageView
      delegate : @
      
    participantsController = new KDListViewController
      itemClass : ChatParticipantView
      delegate : @
    
    @messageInput = new KDHitEnterInputView
      cssClass : 'chat-input'
      callback : (value)=> 
        @emit 'ChatMessageComposed',value if value
        @messageInput.blur()
        @messageInput.setValue ''
        @utils.defer => @messageInput.focus()
    
    @header = new KDView
      cssClass : 'chat-header'
      partial : 'Session Chat'
      click:=>
        if @$().hasClass 'minimized' 
          @header.unsetClass 'new-message'
          @unsetClass 'minimized' 
        else @setClass 'minimized'
    
    @messagesList.on 'ChatMessageClicked', =>
      @utils.defer => @messageInput.setFocus()
      
    @messagesList.on 'click', =>
      @utils.defer => @messageInput.setFocus()
    
    @on 'ChatMessageArrived', (message)=>
      #console.log 'CHAT: Message arrived', message
      messagesController.addItem message
      @utils.defer => 
        @messagesList.$().scrollTop @messagesList.$()[0].scrollHeight
      if @$().hasClass 'minimized'
        @header.setClass 'new-message'
    
    @on 'UserJoined', (user)=>
    @on 'UserLeft', (user)=>
      
  pistachio:->
    """
      {{> @header}}
      {{> @messagesList}}
      <div class="chat-input-wrapper">
      {{> @messageInput}}
      </div>
    """