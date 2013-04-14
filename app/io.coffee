class KodeLectures.Controllers.FileIOController extends KDController

  constructor:->
    super
    
    @kiteController = KD.getSingleton "kiteController"
    
    {@nickname} = KD.whoami().profile
    @name       = 'kodelectures'
    @appPath      = "/Users/#{@nickname}/Applications"
    @basePath     = "#{@appPath}/#{@name}.kdapp"
    
    @attachListeners()
  
  importCourseFromURL:(url,callback)->
    baseUrl = url
    url = url.replace /\/$/, ''
    url += '/manifest.json' unless url.match /manifest.json$/
    
    command = "curl -kL '#{url}'"
    console.log 'importing from url', url
    
    @kiteController.run command, (err,res)=>
      if err then console.log err
      
      else        
        console.log 'parsing manifest.json'
        try 
          course = JSON.parse res
        catch e 
          console.log 'parse failed',e
        
        if course 
          
          @kiteController.run "mkdir #{@basePath}/courses/#{course.path}", (err,res)=>
            @kiteController.run "curl -kL '#{url}' > #{@basePath}/courses/#{course.path}/manifest.json"
            
            console.log 'importing course',course?.title
            
            if course.lectures
              for lecture in course.lectures
                console.log 'importing lecture',lecture.title
                if lecture.files                   
                  for file in lecture.files 
                    console.log "importing file #{baseUrl}/#{file} to #{@basePath}/courses/#{course.path}/#{file}"
                    @kiteController.run "curl -kL '#{baseUrl}/#{file}' > #{@basePath}/courses/#{course.path}/#{file}", (err,res)=>
                        if err 
                          console.log 'file could not be imported', err
                        else
                          console.log 'file successfully imported', err, res
                          
            
            KD.utils.wait 2000, =>
              @emit 'NewCourseImported', course
              callback course
          
    
  
  readFile:(courses,course,lecture,filename,callback)->
    
    currentFile  = "#{@basePath}/courses/#{courses[course].path}/#{filename}"    
    
    codeFileInstance = FSHelper.createFileFromPath currentFile
    codeFileInstance.fetchContents callback
   
  saveFile:(courses,course,lecture,filename,value,callback=->)->
    
    currentFile  = "#{@basePath}/courses/#{courses[course].path}/#{filename}"
    
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
          
