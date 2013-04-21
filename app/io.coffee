class KodeLectures.Controllers.FileIOController extends KDController

  daisy = (args, fn) ->
    setTimeout args.next = ->
      if (f = args.shift()) then !!f(args) or yes else no
    , 0

  constructor:->
    super
    
    @kiteController = KD.getSingleton "kiteController"
    
    {@nickname} = KD.whoami().profile
    @name       = 'KodeLectures'
    @appPath      = "/Users/#{@nickname}/Applications"
    @basePath     = "#{@appPath}/#{@name}.kdapp"
    
    @isInstructor = yes
    @allowBroadcast = yes
    
    @attachListeners()
  
  broadcastMessage:(message,callback=->)->
    console.log 'FIREBASE: Broadcasting:',message
    if @firebaseRef and @allowBroadcast
      @firebaseRef.update message, =>
        callback arguments
        @utils.defer =>
          if message.join
            @firebaseRef.child('join').remove =>
              console.log 'removed join'
          if message.leave
            @firebaseRef.child('leave').remove =>
              console.log 'remove leave'
          #
      
  removeChild:(key,callback=->)->
    console.log 'FIREBASE: Removing:',key
    if @firebaseRef and @allowBroadcast
      @firebaseRef.remove key

  attachFirebase:(sessionKey,callback=->)->
  
    if sessionKey is @currentSessionKey 
      callback sessionKey
      console.log 'FIREBASE: You are trying to attach the session you are currently in.'
      return null
      
    @previousSessionKey = @currentSessionKey if @currenSessionKey
    @currentSessionKey = sessionKey or "kl-#{KD.utils.generatePassword 6, no}"
  
    if @firebaseRef then console.warn 'Overwriting instance of firebase.'
    
    console.log 'FIREBASE: Attaching with session key:',@currentSessionKey
    
    @firebaseRef = new Firebase("https://kodelectures.firebaseIO.com/").child @currentSessionKey
    
    @instantiated = no
    
    @firebaseRef.on 'value', (snapshot)=>
      name = snapshot.name()
      message = snapshot.val()
      #console.log 'Firebase transmitted this message (value):',name,message
      
      # first check for owner 
      unless @instantiated
        unless message?.owner?
          console.log 'FIREBASE: This Firebase has no owner, must be mine!'
    
          console.log 'FIREBASE: Well then, setting default data to Firebase'  
          @broadcastMessage
            createdAt   : new Date().getTime()
            owner       : @nickname
            messages    : ['This session is now available.']
          
          , => 
            @isInstructor = yes
            @instantiated = yes 
            callback @currentSessionKey, 'fresh'
        
        else 
          if message.owner is @nickname
            console.log 'FIREBASE: Neat, this is my Firebase.'
            @isInstructor = yes
            @instantiated = yes 
            callback @currentSessionKey

          else 
            console.log 'FIREBASE: This is someone elses Firebase. Cool!'
            @broadcastMessage {join:KD.whoami().profile.nickname}
            @isInstructor = no
            @instantiated = yes 
            callback @currentSessionKey
      
          
    @firebaseRef.on 'child_added', (snapshot)=>
      name = snapshot.name()
      message = snapshot.val()
     # console.log 'Firebase transmitted this message (child_added):',name,message
      @handleMessage name, message
     
    @firebaseRef.on 'child_changed', (snapshot)=>
      name = snapshot.name()
      message = snapshot.val()
      #console.log 'Firebase transmitted this message (child_changed):',name,message
      @handleMessage name, message
       
    @firebaseRef.on 'child_removed', (snapshot)=>
      name = snapshot.name()
      message = snapshot.val()
      #console.log 'Firebase transmitted this message (child_removed):',name,message     
      
    @firebaseRef.on 'child_moved', (snapshot)=>
      name = snapshot.name()
      message = snapshot.val()
     # console.log 'Firebase transmitted this message (child_moved):',name,message

  handleMessage:(name,message)->
    switch name
      when 'location'
        if message is 'lectures' then @emit 'LectureRequested' 
        if message is 'courses' then @emit 'CourseRequested' 
      when 'editorContent'
        @emit 'EditorContentChanged', message
      when 'language'
        @emit 'LanguageChanged', message
      when 'course'
        @emit 'CourseChanged', message
      when 'lecture'
        @emit 'LectureChanged', message
      when 'join'
        @emit 'UserJoined', message
      when 'leave'
        @emit 'UserLeft', message
      

  checkAppIntegrity:(callback=->)->
    
    courses = null
    error = null
    daisy queue = [
      =>
        console.log 'Checking for courses directory'
        @kiteController.run "stat '#{@basePath}/courses'", (err,res)=>
          if err
            callback "Course directory could not be found at #{@basePath/courses}"
          else
            queue.next()
      =>
        console.log 'Checking for courses inside courses directory'
        @kiteController.run "ls #{@basePath}/courses", (err,res)=> 
          courses = res.trim().split "\n"
          if not courses.length or courses[0] is ""
            console.log 'No courses found. Skipping manifest check.'
            queue.next()
          else   
            console.log "#{courses.length} courses found."
            console.log 'Scanning course directories for manifest.json'
            remainingCount = courses.length
            for course in courses
              do =>
                filePath = "#{@basePath}/courses/#{course}/manifest.json"
                if course then @kiteController.run "cat #{filePath}", (err,manifest)=>
                  try
                    newCourse = JSON.parse manifest
                  catch e
                    callback error = "Unable to parse #{filePath} with exception: #{e}"
                                  
                  if newCourse then @checkManifestIntegrity newCourse, (err)=>
                    if err
                      callback error = "Malformed data in #{filePath}: #{err}"
                    else 
                      if --remainingCount is 0 then queue.next()
      -> 
        unless error
          console.log "%c✓ Integrity Check has finished successfully. App is starting.", 'color:#00bb00'
          callback()
        else 
          console.log "%c✗ Integrity Check has finished with errors. Please fix them.", 'color:#bb0000;'
      ]
    
  checkManifestIntegrity:(manifest,callback=->)->
    console.log "Checking manifest for #{manifest.title}"
    
    courseErrorMatrix =
      "title":'Course Title is missing (title)'
      "description":'Course description is missing (description)'
      "path":'Course Path is missing (path). It should specify the path of the lecture, including any file extension (e.g. "CoffeeScript.kdlecture")'
      "originType":'Course origin type is missing (originType). Please specify either "url" or "git".'
      "originUrl":'Course origin url is missing (originUrl). Please specify a URL to either a repository or a manifest.json file.'
      "lectures":'Course has no lectures (lectures).'
      
    lectureErrorMatrix =
      "title":"Lecture Title is missing (title).",
      "summary":"Lecture Summary is missing (summary).",
      "expectedResults":"Lecture expected result is missing (expectedResults). Set to null if there is no expected result.",
      "submitSuccess":"Lecture success message is missing (submitSuccess). Set to empty string if not needed.",
      "submitFailure":"Lecture failure message is missing (submitFailure). Set to empty string if not needed.",
      "language":"Lecture language is missing (language). Set to 'text' if you don't want to specify a language.",
      "previewType":"Lecture preview type is missing (previewType). Set to either 'code-preview', 'terminal' or 'execute-html'.",        
      "execute": "Lecture execute command is missing (execute). Set to empty string if not needed.",
      "files" : "Lecture files are missing (files). This needs to be an array of at least one string, pointing to the files of the lecture. The first file will be loaded into the editor.",
      
    for check,errorMessage of courseErrorMatrix
      unless manifest[check] isnt undefined
        callback errorMessage
    
    for lecture,lectureIndex in manifest.lectures
      for check,errorMessage of lectureErrorMatrix
        unless lecture[check] isnt undefined
          callback "In lecture #{lectureIndex}: #{errorMessage}"
  
    callback null
  
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
      
      command = "ls -t #{coursePath}" 
     
      @kiteController.run command, (err, res)=>
        unless err
          courses = res.trim().split "\n"
          for course in courses
            if course then @kiteController.run "cat #{coursePath}/#{course}/manifest.json", (err,manifest)=>
              try
                newCourse = JSON.parse manifest
                @emit 'NewCourseImported', newCourse
              catch e
                console.log 'Reading and/or parsing manifest.json failed with : ',e,err
          
