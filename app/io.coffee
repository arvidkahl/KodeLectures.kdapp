class KodeLectures.Controllers.FileIOController extends KDController

  constructor:->
    super
    
    @kiteController = KD.getSingleton "kiteController"
    
    {@nickname} = KD.whoami().profile
    @name       = 'KodeLectures'
    @appPath      = "/Users/#{@nickname}/Applications"
    @basePath     = "#{@appPath}/#{@name}.kdapp"
    
    @attachListeners()
  
  generateSymlinkedPreview:(previewPath,coursePath,callback=->)->
    
    id = KD.utils.getRandomNumber 50000
    publicURL = "https://#{@nickname}.koding.com/.kodelectures/#{id}/#{previewPath}"
    publicBasePath = "/Users/#{@nickname}/Sites/#{@nickname}.koding.com/website/.kodelectures"
    courseBasePath = "/Users/#{@nickname}/Applications/KodeLectures.kdapp/courses/#{coursePath}"
    command = "mkdir #{publicBasePath};ln -s '#{courseBasePath}' '#{publicBasePath}/#{id}';"
    
    console.log 'Cleaning up symlinks in public directory (if necessary)'
    @kiteController.run "find #{publicBasePath}/ -maxdepth 1 -type l -exec rm -f {} \\;", (cleanupErr,cleanupRes)=>
     console.log 'Cleaning up failed with error: ',cleanupErr if cleanupErr
     @kiteController.run command, (err,res) => 
       callback err,res,publicURL
   
  resetCourseFiles:(courses,course,type,callback=->)->
    if type is 'git' 
      path = courses[course].path.replace /\.\.\//, ''
      command = "cd #{@basePath}/courses/#{path}; git reset --hard HEAD"
    
    console.log "Resetting course '#{courses[course].title}' if possible"
    
    if command then @kiteController.run command , (err,res)=>  
      if err 
        console.log 'Resetting failed with error :',err
        callback err
      else 
        console.log "Resetting completed",err,res
        callback err,res
        @emit 'CourseFilesReset',courses[course]
      
  removeCourse:(courses,course,callback=->)->

    {path} = courses[course]
    unless path
      callback 'No path available.'
    else 
     path = path.replace /\.\.\//, '' # should prevent ../ traversal
     console.log "Attempting to remove course at #{path}"
     @kiteController.run "rm -rf #{@basePath}/courses/#{path}", (err,res)=>
      if err
        callback err
        console.log "Removing the course failed with error : #{err}"
      else 
        console.log 'Course successfully removed'
        callback err,res
        
  
  importCourseFromRepository:(url, type, callback=->)->
    
    if type is 'git' 
      command = "cd #{@basePath}/courses; git clone #{url}"
    
    console.log "Importing a course from #{type} repository at #{url}"
    
    if command then @kiteController.run command , (err,res)=>
      
      console.log 'Import finished.',err
      
      newCourseName = url.replace(/\/$/,'').substring(url.lastIndexOf("/") + 1, url.length).replace(/\.git$/,'')

      manifestInstance = FSHelper.createFileFromPath "#{@basePath}/courses/#{newCourseName}/manifest.json"
      manifestInstance.fetchContents (err,res)=>
        console.log 'Parsing manifest.json' #,err,res
        
        if err then callback err
        else
          try 
            course = JSON.parse res
          catch e
            console.log 'Parse fauled with exception ',e
          
          if course 
            console.log "Successfully imported course #{course.title} from #{url}"
            @emit 'NewCourseImported',course
            callback course
            
  importCourseFromURL:(url,callback=->)->
    baseUrl = url
    url = url.replace /\/$/, ''
    url += '/manifest.json' unless url.match /manifest.json$/
    
    command = "curl -kL '#{url}'"
    console.log "Importing a course from url #{url}"
    
    @kiteController.run command, (err,res)=>
      if err then console.log 'Importing via url failed with error : ', err
      
      else        
        console.log 'Parsing manifest.json'
        try 
          course = JSON.parse res
        catch e 
          console.log 'Parse failed with exception : ',e
        
        if course 
          
          @kiteController.run "mkdir #{@basePath}/courses/#{course.path}", (err,res)=>
            @kiteController.run "curl -kL '#{url}' > #{@basePath}/courses/#{course.path}/manifest.json"
            
            console.log "Importing course '#{course.title}' from manifest.json data"
            
            if course.lectures
              for lecture in course.lectures
                console.log "Importing lecture #{lecture.title}"
                if lecture.files                   
                  for file in lecture.files 
                    console.log "Importing file #{baseUrl}/#{file} to #{@basePath}/courses/#{course.path}/#{file}"
                    @kiteController.run "curl -kL '#{baseUrl}/#{file}' > #{@basePath}/courses/#{course.path}/#{file}", (err,res)=>
                        if err 
                          console.log "File #{file} could not be imported, an error occured : ", err
                        else
                          console.log "File #{file} successfully imported"
                          
            # this timeout is a hack. basically, i need to wait until everything is imported. then fire the event/cb
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
                console.log 'Reading and/or parsing manifest.json failed with : ',e,err
          
