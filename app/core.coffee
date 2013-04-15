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
  
  previewCode: (code, execute)->
    return if not @active 
    
    unless not code or code is ''
    
      kiteController = KD.getSingleton "kiteController"
      
      command = switch @mainView.currentLang
        
        when 'javascript' then "echo '#{window.btoa code}' | base64 -d > temp.js; node temp.js;"
        when 'coffee'     then "echo '#{window.btoa code}' | base64 -d > temp.coffee; coffee temp.coffee -n;"
        when 'ruby'       then "echo '#{window.btoa code}' | base64 -d > temp.rb; ruby temp.rb;"
        when 'python'     then "echo '#{window.btoa code}' | base64 -d > temp.py; python temp.py;" 
        
      #if execute
        #command = ""execute
      #
      {ioController,courses,lastSelectedCourse:course,lastSelectedItem:lecture} = @mainView
      
      ioController.runFile courses,course,lecture,execute, (err,res)=>
      #kiteController.run command, (err, res)=>
      
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
      #console.log "hiding #{type}"
      @hide() 
    else 
      #console.log "showing #{type}"
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
      partial : @getData().title
  
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
  
  pistachio:->
    """
    {{> @lectureTitle}}
    """
  
  click:->
    @getDelegate().emit 'LectureSelected', @getData()
    
class KodeLectures.Views.CourseSelectionItemView extends KDListItemView  
  {CourseLectureListItemView} = KodeLectures.Views
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
  
    @lectureController = new KDListViewController
      itemClass : CourseLectureListItemView
      delegate : @ 
    , items : @getData().lectures
    @lectureList = @lectureController.getView()
  
    @lectureController.listView.on 'LectureSelected', (data)=>
      @getDelegate().emit 'LectureSelected', {lecture:data, course:@getData()}
      
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
                    
  
      
  
  viewAppended :->
    @setTemplate @pistachio()
    @template.update()
  
  click:->
    @getDelegate().emit 'CourseSelected', @getData()
  
  pistachio:->
    """
    {{> @titleText}}
    {{> @descriptionText}}
    {{> @lectureList }}
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
    
    @on 'NewCourseImported', (course)=>
      @courseController.addItem course
      courses.push course
    
    @courseController.listView.on 'LectureSelected', ({course,lecture})=>
      @mainView.emit 'CourseChanged', courses.indexOf course  
      KD.utils.defer => @mainView.emit 'LectureChanged', course.lectures.indexOf lecture
    
    @courseController.listView.on 'CourseSelected', (course)=>
      @mainView.emit 'CourseChanged', courses.indexOf course

    @courseController.listView.on 'RemoveCourseClicked', ({course,view})=>
      @mainView.ioController.removeCourse courses, courses.indexOf(course), (err,res)=>
        unless err then view.destroy()
    
    @courseController.listView.on 'ResetCourseClicked', ({course,view})=>
      console.log course
      @mainView.ioController.resetCourseFiles courses, courses.indexOf(course), course.originType, (err,res)=>
        unless err then new KDNotificationView {title:'Files successfully reset'}
      #
    @courseHeader = new KDView
      cssClass : 'course-header'
      partial : '<h1>Select a  course:</h1>'

  setMainView:(@mainView)->

  pistachio:->
    """
    {{> @courseHeader}}
    {{> @courseView}}
    """