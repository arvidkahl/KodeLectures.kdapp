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

class KodeLectures.Views.TaskView extends JView

  setMainView: (@mainView)->

  constructor:->
    super
    @setClass 'task-view'
  
    console.log 'taskview'
  
    {videoUrl,@codeHintText,@codeHint,embedType,@taskText} = @getData()
    
    @codeHint ?= ''
    @codeHintText ?= ''
    @taskText ?= ''
    
    @embed = new KDView
      cssClass : 'embed'
      partial : if videoUrl and embedType is 'youtube'
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
      partial : "<span class='text'>Assignment</span><span class='data'>#{marked @taskText}</span>"
  
    @resultView = new KDView
      cssClass : 'result-view hidden'
      
    @hintView = new KDView
      cssClass : 'hint-view has-markdown'
      partial : '<span class="text">Show hint</span>'
      click :=>
        @hintView.updatePartial "<span class='text'>Hint</span><span class='data'>#{marked @codeHintText}</span>"
  
    @hintCodeView = new KDView
      cssClass : 'hint-code-view has-markdown'
      partial : '<span class="text">Show solution</span>'
      click :=>
        @hintCodeView.updatePartial "<span class='text'>Solution</span><span class='data'>#{marked @codeHint}</span>"
    
    @on 'LectureChanged',(lecture)=>
      {@codeHint,@codeHintText,@taskText}=lecture
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

    @courseHeader = new KDView
      cssClass : 'course-header'
      partial : '<h1>Select a  course:</h1>'

  setMainView:(@mainView)->

  pistachio:->
    """
    {{> @courseHeader}}
    {{> @courseView}}
    """