class KodeLectures.Controllers.FileIOController extends KDController

  constructor:->
    super
    
    @kiteController = KD.getSingleton "kiteController"
    
    {@nickname} = KD.whoami().profile
    @name       = 'kodelectures'
    @appPath      = "/Users/#{@nickname}/Applications"
    @basePath     = "#{@appPath}/#{@name}.kdapp"
    
    @attachListeners()
    
  readFile:(courses,course,lecture,key,callback)->
    
    currentFile  = "#{@basePath}/courses/#{courses[course].path}/#{courses[course].lectures[lecture][key]}"    
    
    codeFileInstance = FSHelper.createFileFromPath currentFile
    codeFileInstance.fetchContents callback
   
  saveFile:(courses,course,lecture,value,callback=->)->
    
    currentFile  = "#{@basePath}/courses/#{courses[course].path}/#{courses[course].lectures[lecture].codeFile}"
    
    codeFileInstance = FSHelper.createFileFromPath currentFile
    codeFileInstance.save value, callback
  
  runFile:(courses,course,lecture,execute,callback)->
    @kiteController.run "cd #{@basePath}/courses/#{courses[course].path};#{execute}", callback  
  
  attachListeners:->
    
    @name      = @name.replace(/.kdapp$/, '')
    root       = "/Users/#{@nickname}/Applications"
    path       = "#{root}/#{@name}.kdapp"
    coursePath = "#{path}/courses"
    
    @on 'CourseImportRequested', =>
      
      command = "ls #{coursePath}" 
     
      @kiteController.run command, (err, res)=>
        unless err
          courses = res.trim().split "\n"
          for course in courses
            @kiteController.run "cat #{coursePath}/#{course}/manifest.json", (err,manifest)=>
              try
                newCourse = JSON.parse manifest
                @emit 'NewCourseImported', newCourse
              catch e
                console.log e
          
